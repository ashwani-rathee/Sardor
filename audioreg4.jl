using Flux
using Flux.Data: DataLoader
using Flux.Optimise: Optimiser, WeightDecay
using Flux: onehotbatch, onecold, normalise, Dropout
using Flux.Losses: logitcrossentropy
using Statistics, Random
using Logging: with_logger
using TensorBoardLogger: TBLogger, tb_overwrite, set_step!, set_step_increment!
using ProgressMeter: @showprogress
import MLDatasets
import BSON
using CUDA
using Glob
using SignalAnalysis
using WAV
using Images
using Random:shuffle
println("Import Done")

labeldict = Dict("left" => 0, "right" => 1, "up" => 2,  "down" => 3)

function ConvNet5(; imgsize=(28,28,1), nclasses=4) 
    return Chain(
            		Flux.normalise,
			Conv((3, 3), imgsize[end]=>80 ,elu),
			MaxPool((2, 2)),
			Dropout(0.25),
		    	flatten,
			Dense(13520, 128, relu), 
			Dropout(0.5),
			Dense(128, nclasses)
          )
end

function read_audio(filepath)
	val, fs = wavread(filepath)
	lengthneed= 16000 - length(val)
	created = zeros(Float32, lengthneed)
	result = vcat(val[:],created)
	spec= spectrogram(result, 255, 128; fs=fs);
        y = imresize(spec.power, (28, 28));
        y = reshape(convert(Array{Float32},y ), (28,28,1));
	return y
end
function get_label(filepath)
	label = split(filepath, "/")[end-1]
	return Float32.(labeldict[label])
end
function loaddata(paths)
	data = zeros(Float32, ( 28,28, 1, length(paths)))
	for (num ,i) in enumerate(paths) 
		data[:,:,:, num] = read_audio(i)
	end
	return data
end


function get_data(args)
    DATASET_PATH = "./mini_speech_commands"
    left = glob("left/*.wav", "./mini_speech_commands")
    right = glob("right/*.wav", "./mini_speech_commands")
    up = glob("up/*.wav", "./mini_speech_commands")
    down = glob("down/*.wav", "./mini_speech_commands")
    datalist = vcat(left, right, up, down)
    filenames = shuffle(datalist)
    train_files = filenames[1:2500]
    val_files = filenames[2500:3300]
    test_files = filenames[3300:4000]
    
    xtrain = loaddata(train_files)
    ytrain =  onehotbatch(map(x->get_label(x), train_files), 0:3)

    xtest = loaddata(val_files)
    ytest =   onehotbatch(map(x->get_label(x), val_files), 0:3)

    train_loader = DataLoader((xtrain, ytrain), batchsize=args.batchsize, shuffle=true)
    test_loader = DataLoader((xtest, ytest),  batchsize=args.batchsize, shuffle=true)
    
    return train_loader, test_loader
end

loss(ŷ, y) = logitcrossentropy(ŷ, y)

function eval_loss_accuracy(loader, model, device)
    l = 0f0
    acc = 0
    ntot = 0
    for (x, y) in loader
        x, y = x |> device, y |> device
        ŷ = model(x)
        l += loss(ŷ, y) * size(x)[end]        
        acc += sum(onecold(ŷ |> cpu) .== onecold(y |> cpu))
        ntot += size(x)[end]
    end
    return (loss = l/ntot |> round4, acc = acc/ntot*100 |> round4)
end

println("Functions Done")

## utility functions
num_params(model) = sum(length, Flux.params(model)) 
round4(x) = round(x, digits=4)

# arguments for the `train` function 
Base.@kwdef mutable struct Args
    η = 3e-4             # learning rate
    λ = 0                # L2 regularizer param, implemented as weight decay
    batchsize = 128      # batch size
    epochs = 50          # number of epochs
    seed = 0             # set seed > 0 for reproducibility
    use_cuda = true      # if true use cuda (if available)
    infotime = 1 	     # report every `infotime` epochs
    checktime = 5        # Save the model every `checktime` epochs. Set to 0 for no checkpoints.
    tblogger = true      # log training with tensorboard
    savepath = "runs/"    # results path
end

function train(; kws...)
    args = Args(; kws...)
    args.seed > 0 && Random.seed!(args.seed)
    use_cuda = args.use_cuda && CUDA.functional()
    
    if use_cuda
        device = gpu
        @info "Training on GPU"
    else
        device = cpu
        @info "Training on CPU"
    end

    ## DATA
    train_loader, test_loader = get_data(args)
    @info "Dataset Speech Commands: $(train_loader.nobs) train and $(test_loader.nobs) test examples"

    ## MODEL AND OPTIMIZER
    model = ConvNet5() |> device
    @info "ConvNet5 model: $(num_params(model)) trainable params"    
    
    ps = Flux.params(model)  

    opt = ADAM(args.η) 
    if args.λ > 0 # add weight decay, equivalent to L2 regularization
        opt = Optimiser(WeightDecay(args.λ), opt)
    end
    
    ## LOGGING UTILITIES
    if args.tblogger 
        tblogger = TBLogger(args.savepath, tb_overwrite)
        set_step_increment!(tblogger, 0) # 0 auto increment since we manually set_step!
        @info "TensorBoard logging at \"$(args.savepath)\""
    end
    
    function report(epoch)
        train = eval_loss_accuracy(train_loader, model, device)
        test = eval_loss_accuracy(test_loader, model, device)        
        println("Epoch: $epoch   Train: $(train)   Test: $(test)")
        if args.tblogger
            set_step!(tblogger, epoch)
            with_logger(tblogger) do
                @info "train" loss=train.loss  acc=train.acc
                @info "test"  loss=test.loss   acc=test.acc
            end
        end
    end
    
    ## TRAINING
    @info "Start Training"
    report(0)
    for epoch in 1:args.epochs
        @showprogress for (x, y) in train_loader
            x, y = x |> device, y |> device
            gs = Flux.gradient(ps) do
                    ŷ = model(x)
                    loss(ŷ, y)
                end

            Flux.Optimise.update!(opt, ps, gs)
        end
        
        ## Printing and logging
        epoch % args.infotime == 0 && report(epoch)
        if args.checktime > 0 && epoch % args.checktime == 0
            !ispath(args.savepath) && mkpath(args.savepath)
            modelpath = joinpath(args.savepath, "model_$(epoch/5).bson") 
            let model = cpu(model) #return model to cpu before serialization
                BSON.@save modelpath model epoch
            end
            @info "Model saved in \"$(modelpath)\""
        end
    end
end
println("Training Coming")


train()



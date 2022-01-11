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

labeldict = Dict("yes" => 1, "go" => 2, "left" => 3, "right" => 4, "up" => 5,  "down" => 6, "stop"=> 7, "no" => 0 )

# ConvNet5 "constructor". 
# The model can be adapted to any image size
# and any number of output classes.


function ConvNet5(; imgsize=(28,28,1), nclasses=8) 
    out_conv_size = (imgsize[1]÷4 - 3, imgsize[2]÷4 - 3, 16)
    
    return Chain(
            Flux.normalise,
	    Conv((3, 3), imgsize[end]=>32, relu),
            Conv((3, 3), 32=>64, relu),
            MaxPool((2, 2)),
            Dropout(0.25),
            flatten,
            Dense(9216, 120, relu), 
            Dropout(0.5),
            Dense(120, nclasses)
          )
end

function imagesload(imglist)
    n = length(imglist);
    data = zeros(Float32, (28,28,1,n));
    labels = onehotbatch(map(x-> labeldict[split(split(x, "/")[end], "#")[1]], imglist), 0:7);
    for (num,i) in enumerate(imglist)
        img = load(i)
        # println(size(img))
        img = imresize(img, (28,28))
        img = reshape(convert(Array{Float32}, Gray.(img)), (28, 28, 1));
        # img = channelview(img);
        # println(size(img))
        data[:,:,:,num] = img;
        # break
    end
    return data, labels
end

function get_data(args)
    ImgList = glob("**.png", "./datasetspectro")
    ImgList= shuffle(ImgList)
    train_files = ImgList[1:6000]
    val_files = ImgList[6000:7000]
    test_files = ImgList[7000:7730]
    
    xtrain, ytrain = imagesload(train_files)
    xtest, ytest = imagesload(test_files)    
    
    # xtrain = loaddata(train_files)
    # ytrain =  onehotbatch(map(x->get_label(x), train_files), 0:7)

    # xtest = loaddata1(val_files)
    # ytest =   onehotbatch(map(x->get_label(x), val_files), 0:7)
    

    train_loader = DataLoader((xtrain, ytrain), batchsize=args.batchsize, shuffle=true)
    test_loader = DataLoader((xtest, ytest),  batchsize=args.batchsize)
    
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
            modelpath = joinpath(args.savepath, "model.bson") 
            let model = cpu(model) #return model to cpu before serialization
                BSON.@save modelpath model epoch
            end
            @info "Model saved in \"$(modelpath)\""
        end
    end
end
println("Training Coming")


train()



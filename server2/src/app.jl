using Genie
using Genie.Router
import Genie.Renderer.Json: json
using Genie.Renderer.Json, Genie.Requests

using Flux
using Flux: Chain, Dense, Conv, MaxPool, flatten, relu, cpu
using BSON
using Flux: onehotbatch, onecold, normalise, Dropout
using DataStructures
using StatsBase
#using GLMakie
#using Images

#img = load("./../datasetspectro2/down#3ae5c04f_nohash_0.wav.png")
#fig = Figure(size = (1000, 700), title = "Object Tracker")
#ax = GLMakie.Axis(
   # fig[1, 1],aspect = DataAspect())
#node = Node(rotr90(img))
#makieimg = image!(ax, node)

#display(fig)

function ConvNet5(; imgsize = (28, 28, 1), nclasses = 4)
    return Chain(
        normalise,
        Conv((3, 3), imgsize[end] => 32, relu),
        Conv((3, 3), 32 => 64, relu),
        MaxPool((2, 2)),
        Dropout(0.25),
        flatten,
        Dense(9216, 120, relu),
        Dropout(0.5),
        Dense(120, nclasses),
    )
end

predictdict = Dict(
    0 => "left",
    1 => "right",
    2 => "up",
    3 => "down",
)

device = cpu
model = ConvNet5() |> device

BSON.@load "./src/model_4.0.bson" model
queueofdata = Queue{Any}();
xtrain = zeros(Float32, (28, 28, 1, 15))
function launchServer(port)

    Genie.config.run_as_server = true
    Genie.config.server_host = "0.0.0.0"
    Genie.config.server_port = port

    println("port set to $(port)")

    #route("/") do
    #    "Hi there! This is server 1"
    #end

    route("/adddata", method = POST) do
        data1 = eval(Meta.parse(rawpayload()))
        enqueue!(queueofdata, data1);
        data1 = nothing 
        #println("Current queue after post: ",length(queueofdata))
    end

    route("/digitreg", method = POST) do
        data = eval(Meta.parse(rawpayload()))
        data = reshape(data, (28, 28, 1))
        xtrain = zeros(Float32, (28, 28, 1, 2))
        xtrain[:, :, :, 1] = data
        results = model(xtrain)
        final = predictdict[findmax(results[:, 1])[2]-1]
        return final
    end

    route("/digitreg", method = GET) do
    	#println("Current queue: ",length(queueofdata))
    	if length(queueofdata) >= 1  
	    	#node[] = rotr90(RGB{N0f8}.(dequeue!(queueofdata)))
	    	l = length(queueofdata)
		map(x-> xtrain[:,:,:,x] =  reshape(Float32.(dequeue!(queueofdata)), (28, 28, 1)), 1:l)
		
		results = model(xtrain)
		results = map(x-> predictdict[findmax(results[:, x])[2]-1],1:l) 
		println("This here:",results)
		dictfinal = countmap(results)
		a = findmax(dictfinal)
		#if dictfinal[a[2]] == 3
			#return	"Idk what"
		#end        
		# println(a)
		return a[2]
	end
    end

    Genie.AppServer.startup(async = false)
end

# launchServer(parse(Int, ARGS[1]))
launchServer(8003)



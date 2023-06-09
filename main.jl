using EKIdemo
using LinearAlgebra
using Random
using Plots

# Set up model
p_true = [0,2]
x_data = [1.,2.,3.,4.,5.]
y_data = [2.,4.,6.,8.,10.]

forwardModel(p) = p[1] .+ p[2].*x_data

Ndata = length(x_data)
Nparameter = 2
Nensemble = 100

ekiModel = initialize_EKI(
    ekiSettings=EKIsettings(
        Ndata=Ndata,
        Nensemble=Nensemble,
        Nparameter=Nparameter
    ),
    data=y_data,
    parametersInit=()->randn(eltype(y_data),Nparameter),
    forwardModel=forwardModel
)

ekiResult = runEKI(ekiModel)

@gif for parameters in ekiResult.parameterArray
    scatter(parameters[1,:],parameters[2,:],label="Ensemble parameters")
    scatter!([p_true[1]],[p_true[2]],label="True parameters")
    plot!(xlim=(-2.5,2.5),ylim=(0,5))
end
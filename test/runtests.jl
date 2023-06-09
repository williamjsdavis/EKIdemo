using EKIdemo
using Test
using Random

x_data = [1.,2.,3.,4.,5.]
y_data = [2.,4.,6.,8.,10.]

forwardModel(p) = p[1] .+ p[2].*x_data

Ndata = length(x_data)
Nparameter = 2
Nensemble = 100
verbose = false

ekiModel = initialize_EKI(
    ekiSettings=EKIsettings(
        Ndata=Ndata,
        Nensemble=Nensemble,
        Nparameter=Nparameter,
        verbose=verbose
    ),
    data=y_data,
    parametersInit=()->randn(eltype(y_data),Nparameter),
    forwardModel=forwardModel
)

ekiSettingsOther=EKIsettings(
    Ndata=Ndata,
    Nensemble=Nensemble,
    Nparameter=Nparameter
)

@testset "EKI init." begin
    @test ekiModel.ekiSettings.Ndata == Ndata
    @test ekiModel.ekiSettings.Nensemble == Nensemble
    @test ekiModel.ekiSettings.Nparameter == Nparameter
    @test ekiModel.ekiSettings.verbose == verbose
    @test ekiSettingsOther.verbose == true
    @test all(ekiModel.data .== y_data)
    @test size(ekiModel.data) == (Ndata,)
    @test size(ekiModel.parameters) == (Nparameter,Nensemble)
    @test size(ekiModel.modelPredictions) == (Ndata,Nensemble)
    @test isa(ekiModel.forwardModel,Function)
end

maxIts = 25
ekiResult = runEKI(ekiModel,maxIts=maxIts)

@testset "EKI result" begin
    @test size(ekiResult.parametersSolution) == (Nparameter,)
    @test size(ekiResult.modelPredictionSolutions) == (Ndata,)
    @test size(ekiResult.parameterArray) == (maxIts,)
    @test size(first(ekiResult.parameterArray)) == (Nparameter,Nensemble)
end
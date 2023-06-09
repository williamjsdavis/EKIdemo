module EKIdemo

using Base: OneTo
using LinearAlgebra: norm, I
using Random: randn

export EKIsettings
export initialize_EKI, set_initial_parameters
export runEKI

struct EKIsettings{T<:Int}
    Ndata::T
    Nensemble::T
    Nparameter::T
    verbose::Bool
end
EKIsettings(;
    Ndata,
    Nensemble,
    Nparameter,
    verbose=true
) = EKIsettings(
    Ndata,
    Nensemble,
    Nparameter,
    verbose
)

mutable struct EKImodel{T}
    ekiSettings::EKIsettings
    data::Vector{T}
    parameters::Matrix{T}
    modelPredictions::Matrix{T}
    forwardModel
end
function initialize_EKI(;
        ekiSettings::EKIsettings,
        data,
        parametersInit,
        forwardModel)
    
    modelPredictions = hcat(
        [zeros(eltype(data),ekiSettings.Ndata) for _ in OneTo(ekiSettings.Nensemble)]...
    )
    parameters = hcat(
        [parametersInit() for _ in OneTo(ekiSettings.Nensemble)]...
    )
    return EKImodel(
        ekiSettings,
        data,
        parameters,
        modelPredictions,
        forwardModel
    )
end

rms(x) = sqrt(sum(x.^2.) / length(x))

struct EKIresult{T}
    parametersSolution::Vector{T}
    modelPredictionSolutions::Vector{T}
    parameterArray::Vector{Matrix{T}}
end

function runEKI(ekiModel::EKImodel;maxIts=25,tolTarget=0.01)
    its = 0
    run = true
    rms_prev = Inf
    p_array = Vector{Matrix{eltype(ekiModel.parameters)}}(undef,0)
    u = ekiModel.parameters
    g = ekiModel.modelPredictions
    K = ekiModel.ekiSettings.Nensemble
    M = ekiModel.ekiSettings.Ndata
    while run == true
        # Run iteration
        its += 1
        push!(p_array,u)

        # 1. Compute forward model
        for i = 1:K
            g[:,i] = ekiModel.forwardModel(u[:,i])
        end

        # 2. Compute the row means
        ubar = sum(u,dims=2)/K
        gbar = sum(g,dims=2)/K

        # Exit condition : check rms
        rms_val = rms(norm(ekiModel.data .- ekiModel.forwardModel(ubar)))
        
        ekiModel.ekiSettings.verbose && println(rms_val)
        
        if abs(rms_val - rms_prev) < tolTarget
            run = false
        end
    
        # 3. Compute covariances Cug & Cgg
        Cug = (1/(K-1)) * (u .- ubar) * (g .- gbar)'
        Cgg = (1/(K-1)) * (g .- gbar) * (g .- gbar)'
    
        # 4. Perturb data vector
        ywig = ekiModel.data .+ 0.1*randn(M)
    
        # 5. Ensemble update step
        u_update = Cug * ((Cgg + I)\(ywig .- g))
        u = u .+ 0.1*u_update
    
        # Exit condition: maxIts
        if its >= maxIts
            run = false
        end
    end
    uSol = sum(u,dims=2)/K
    gSol = ekiModel.forwardModel(uSol)
    return EKIresult(
        vec(uSol),
        vec(gSol),
        p_array
    )
end

end # module EKIdemo

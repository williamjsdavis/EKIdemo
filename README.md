# EKIdemo
Ensemble Kalman Inversion demo in Julia

## Description

This package provides a simple implementation and a short demo of (unregularized) ensemble Kalman inversion (EKI). 

## Use

The EKI method can be set up using the following function:

```julia
ekiModel = initialize_EKI(
    ekiSettings=EKIsettings(
        Ndata=Ndata,
        Nensemble=Nensemble,
        Nparameter=Nparameter
    ),
    data=data,
    parametersInit=()->randn(eltype(y_data),Nparameter),
    forwardModel=forwardModel
)
```

Then, running the inversion is performed with:

```julia
ekiResult = runEKI(ekiModel)
```

## Demo

In the `main.jl` file, a short demo is given for a parameter estimation problem. The results of the inversion are shown in the animation below.

![Animation of ensemble parameter estimates converging on the true parameter value.](https://github.com/williamjsdavis/EKIdemo/assets/38541020/8245b9f7-561e-47ec-89fa-d1b5f55535e0)

## TODO

 - [ ] Add regularization option

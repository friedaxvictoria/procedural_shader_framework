// Copyright Epic Games, Inc. All Rights Reserved.

#include "ProceduralShaderFramework.h"
#include "ShaderCompiler.h"
#include "ShaderCore.h"
#include "ShaderCompilerCore.h"
#include "ShaderCore.h"
#include "ShaderCompiler.h"

#define LOCTEXT_NAMESPACE "FProceduralShaderFrameworkModule"

void FProceduralShaderFrameworkModule::StartupModule()
{
	// This code will execute after your module is loaded into memory; the exact timing is specified in the .uplugin file per-module
	CopyShaderFilesToProject();
	UE_LOG(LogTemp, Log, TEXT("FROM STARTUP MODULE"));
	FString ShaderDir = FPaths::Combine(FPaths::ProjectDir(), TEXT("Shaders"));
	if(!AllShaderSourceDirectoryMappings().Contains(TEXT("/ProceduralShaderFramework"))) {
		AddShaderSourceDirectoryMapping(TEXT("/ProceduralShaderFramework"), ShaderDir);
	}
}

void FProceduralShaderFrameworkModule::ShutdownModule()
{
	// This function may be called during shutdown to clean up your module.  For modules that support dynamic reloading,
	// we call this function before unloading the module.
	UE_LOG(LogTemp, Warning, TEXT("ProceduralShaderFramework: ShutdownModule called."));
}

#undef LOCTEXT_NAMESPACE
	
IMPLEMENT_MODULE(FProceduralShaderFrameworkModule, ProceduralShaderFramework)
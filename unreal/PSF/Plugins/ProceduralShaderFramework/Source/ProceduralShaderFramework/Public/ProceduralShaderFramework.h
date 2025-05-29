// Copyright Epic Games, Inc. All Rights Reserved.

#pragma once

#include "Modules/ModuleManager.h"
#include "Misc/Paths.h"
#include "HAL/FileManager.h"
#include "Misc/FileHelper.h"
#include "Interfaces/IPluginManager.h"

class FProceduralShaderFrameworkModule : public IModuleInterface
{
public:

	/** IModuleInterface implementation */
	virtual void StartupModule() override;
	virtual void ShutdownModule() override;


};


void CopyShaderFilesToProject()
{
    FString PluginShaderDir = FPaths::Combine(IPluginManager::Get().FindPlugin(TEXT("ProceduralShaderFramework"))->GetBaseDir(), TEXT("Shaders"));
    FString ProjectShaderDir = FPaths::ProjectDir() / TEXT("Shaders");

    UE_LOG(LogTemp, Log, TEXT("COPY SHADERS CALLED"));

    IFileManager &FileManager = IFileManager::Get();

    // Ensure project shader dir exists
    FileManager.MakeDirectory(*ProjectShaderDir, true);

    // List .ush files in plugin shader folder
    TArray<FString> ShaderFiles;
    FileManager.FindFiles(ShaderFiles, *PluginShaderDir, TEXT("*.ush"));

    for(const FString &FileName : ShaderFiles)
    {
        FString SourceFile = FPaths::Combine(PluginShaderDir, FileName);
        FString DestFile = FPaths::Combine(ProjectShaderDir, FileName);


        // Overwrite if different or not exists
        
        UE_LOG(LogTemp, Log, TEXT("Copying %s -> %s"), *SourceFile, *DestFile);
        FileManager.Copy(*DestFile, *SourceFile);
    }
}
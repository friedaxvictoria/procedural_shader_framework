// Copyright Epic Games, Inc. All Rights Reserved.

#pragma once

#include "Modules/ModuleManager.h"
#include "Misc/Paths.h"
#include "HAL/FileManager.h"
#include "Misc/FileHelper.h"
#include "Interfaces/IPluginManager.h"
#include "Widgets/Input/SMultiLineEditableTextBox.h"


class FToolBarBuilder;
class FMenuBuilder;

class FProceduralShaderFrameworkModule : public IModuleInterface
{
public:

	/** IModuleInterface implementation */
	virtual void StartupModule() override;
	virtual void ShutdownModule() override;

private:
    /** This function will be bound to Command (by default it will bring up plugin window) */
    void PluginButtonClicked();
    TSharedPtr<SMultiLineEditableTextBox> MultiLineTextBox;
    FString ShaderDir;
private:

    void RegisterMenus();

    TSharedRef<class SDockTab> OnSpawnPluginTab(const class FSpawnTabArgs &SpawnTabArgs);

private:
    TSharedPtr<class FUICommandList> PluginCommands;

    void WriteShaderFunctionToFile();
    void GenerateMaterialFunction();
    void ReplaceBetweenMarkers(const FString &StartMarker, const FString &EndMarker, const FString &Replacement);

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
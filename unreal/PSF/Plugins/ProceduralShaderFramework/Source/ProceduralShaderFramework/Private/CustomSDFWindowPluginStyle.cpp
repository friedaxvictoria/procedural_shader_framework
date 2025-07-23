// Copyright Epic Games, Inc. All Rights Reserved.

#include "CustomSDFWindowPluginStyle.h"
#include "Styling/SlateStyleRegistry.h"
#include "Framework/Application/SlateApplication.h"
#include "Slate/SlateGameResources.h"
#include "Interfaces/IPluginManager.h"
#include "Styling/SlateStyleMacros.h"

#define RootToContentDir Style->RootToContentDir

TSharedPtr<FSlateStyleSet> FCustomSDFWindowPluginStyle::StyleInstance = nullptr;

void FCustomSDFWindowPluginStyle::Initialize()
{
	if (!StyleInstance.IsValid())
	{
		StyleInstance = Create();
		FSlateStyleRegistry::RegisterSlateStyle(*StyleInstance);
	}
}

void FCustomSDFWindowPluginStyle::Shutdown()
{
	FSlateStyleRegistry::UnRegisterSlateStyle(*StyleInstance);
	ensure(StyleInstance.IsUnique());
	StyleInstance.Reset();
}

FName FCustomSDFWindowPluginStyle::GetStyleSetName()
{
	static FName StyleSetName(TEXT("CustomSDFWindowPluginStyle"));
	return StyleSetName;
}

const FVector2D Icon16x16(16.0f, 16.0f);
const FVector2D Icon20x20(20.0f, 20.0f);

TSharedRef< FSlateStyleSet > FCustomSDFWindowPluginStyle::Create()
{
	TSharedRef< FSlateStyleSet > Style = MakeShareable(new FSlateStyleSet("CustomSDFWindowPluginStyle"));

	TSharedPtr<IPlugin> Plugin = IPluginManager::Get().FindPlugin(TEXT("ProceduralShaderFramework"));
	if(Plugin.IsValid())
	{
		Style->SetContentRoot(Plugin->GetBaseDir() / TEXT("Resources"));
	}
	else
	{
		UE_LOG(LogTemp, Warning, TEXT("Could not find plugin 'ProceduralShaderFramework'. Style content root not set."));
	}

	Style->Set("CustomSDFWindowPlugin.OpenPluginWindow", new IMAGE_BRUSH_SVG(TEXT("PlaceholderButtonIcon"), Icon20x20));

	return Style;
}

void FCustomSDFWindowPluginStyle::ReloadTextures()
{
	if (FSlateApplication::IsInitialized())
	{

		FSlateRenderer* Renderer = FSlateApplication::Get().GetRenderer();
		if(Renderer)
		{
			Renderer->ReloadTextureResources();
		}

	}
}

const ISlateStyle& FCustomSDFWindowPluginStyle::Get()
{
	return *StyleInstance;
}

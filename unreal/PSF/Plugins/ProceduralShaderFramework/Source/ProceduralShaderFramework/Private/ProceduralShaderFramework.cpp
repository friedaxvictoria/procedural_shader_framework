// Copyright Epic Games, Inc. All Rights Reserved.

#include "ProceduralShaderFramework.h"
#include "CustomSDFWindowPluginStyle.h"
#include "CustomSDFWindowPluginCommands.h"
#include "ShaderCompiler.h"
#include "ShaderCore.h"
#include "ShaderCompilerCore.h"
#include "ShaderCore.h"
#include "ShaderCompiler.h"

#include "AssetToolsModule.h"
#include "Factories/MaterialFunctionFactoryNew.h"
#include "Materials/MaterialFunction.h"
#include "IAssetTools.h"
#include "Materials/MaterialExpressionFunctionInput.h"
#include "Materials/MaterialExpressionFunctionOutput.h"
#include "Materials/MaterialExpressionCustom.h"
#include "MaterialShared.h"
#include "Materials/MaterialExpressionBreakMaterialAttributes.h"
#include "ObjectTools.h"

static const FName CustomSDFTabName("CustomSDFGenerator");

#define LOCTEXT_NAMESPACE "FProceduralShaderFrameworkModule"


void FProceduralShaderFrameworkModule::StartupModule()
{

	FCustomSDFWindowPluginStyle::Initialize();
	FCustomSDFWindowPluginStyle::ReloadTextures();
	

	FCustomSDFWindowPluginCommands::Register();

	PluginCommands = MakeShareable(new FUICommandList);

	PluginCommands->MapAction(
		FCustomSDFWindowPluginCommands::Get().OpenPluginWindow,
		FExecuteAction::CreateRaw(this, &FProceduralShaderFrameworkModule::PluginButtonClicked),
		FCanExecuteAction());

	UToolMenus::RegisterStartupCallback(FSimpleMulticastDelegate::FDelegate::CreateRaw(this, &FProceduralShaderFrameworkModule::RegisterMenus));

	FGlobalTabmanager::Get()->RegisterNomadTabSpawner(CustomSDFTabName, FOnSpawnTab::CreateRaw(this, &FProceduralShaderFrameworkModule::OnSpawnPluginTab))
		.SetDisplayName(LOCTEXT("FProceduralShaderFrameworkModule", "CustomSDFWindow"))
		.SetMenuType(ETabSpawnerMenuType::Hidden);


	// This code will execute after your module is loaded into memory; the exact timing is specified in the .uplugin file per-module
	CopyShaderFilesToProject();
	ShaderDir = FPaths::Combine(FPaths::ProjectDir(), TEXT("Shaders"));
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


void FProceduralShaderFrameworkModule::PluginButtonClicked() {
	FGlobalTabmanager::Get()->TryInvokeTab(CustomSDFTabName);
}


void FProceduralShaderFrameworkModule::RegisterMenus() {
	// Owner will be used for cleanup in call to UToolMenus::UnregisterOwner
	FToolMenuOwnerScoped OwnerScoped(this);

	{
		UToolMenu *Menu = UToolMenus::Get()->ExtendMenu("LevelEditor.MainMenu.Window");
		{
			FToolMenuSection &Section = Menu->FindOrAddSection("WindowLayout");
			Section.AddMenuEntryWithCommandList(FCustomSDFWindowPluginCommands::Get().OpenPluginWindow, PluginCommands);
		}
	}

	{
		UToolMenu *ToolbarMenu = UToolMenus::Get()->ExtendMenu("LevelEditor.LevelEditorToolBar");
		{
			FToolMenuSection &Section = ToolbarMenu->FindOrAddSection("Settings");
			{
				FToolMenuEntry &Entry = Section.AddEntry(FToolMenuEntry::InitToolBarButton(FCustomSDFWindowPluginCommands::Get().OpenPluginWindow));
				Entry.SetCommandList(PluginCommands);
			}
		}
	}
}

TSharedRef<class SDockTab> FProceduralShaderFrameworkModule::OnSpawnPluginTab(const class FSpawnTabArgs &SpawnTabArgs) {
	FText WidgetText = FText::Format(
		LOCTEXT("WindowWidgetText", "Add code to {0} in {1} to override this window's contents"),
		FText::FromString(TEXT("FCustomSDFWindowModule::OnSpawnPluginTab")),
		FText::FromString(TEXT("TempWindow.cpp"))
	);

	return SNew(SDockTab)
		.TabRole(ETabRole::NomadTab)
		[
			SNew(SVerticalBox)

				// Large Text Input Box
				+ SVerticalBox::Slot()
				.Padding(10)
				.FillHeight(1.0f) // Take as much vertical space as possible
				[
					SNew(SBox)
						.MinDesiredHeight(300.0f)
						[
							SAssignNew(MultiLineTextBox, SMultiLineEditableTextBox)
								.Text(FText::FromString("return length(probePoint) - radius;"))
						]
				]

			// Button
			+ SVerticalBox::Slot()
				.AutoHeight()
				.HAlign(HAlign_Center)
				.Padding(10)
				[
					SNew(SButton)
						.Text(FText::FromString("Run"))
						.OnClicked_Lambda([this] () -> FReply {
							WriteShaderFunctionToFile();
							GenerateMaterialFunction();
							return FReply::Handled();
						})
				]
		];
	
}

void FProceduralShaderFrameworkModule::WriteShaderFunctionToFile()
{
	// Write SDF Function to MyCustomSDF.ush

	if(!MultiLineTextBox.IsValid())
	{
		UE_LOG(LogTemp, Error, TEXT("MultiLineTextBox is not valid."));
		return;
	}

	// Get user-entered text
	FString UserCode = MultiLineTextBox->GetText().ToString();

	// Wrap with a function header
	FString WrappedCode;
	WrappedCode += TEXT("#ifndef PROCEDURAL_SHADER_FRAMEWORK_CUSTOM_SDFs_H\n");
	WrappedCode += TEXT("#define PROCEDURAL_SHADER_FRAMEWORK_CUSTOM_SDFs_H\n");

	WrappedCode += TEXT("float sdMyCustomSDF(float3 probePoint, float time)\n");
	WrappedCode += TEXT("{\n");
	WrappedCode += UserCode.Replace(TEXT("\n"), TEXT("\n    ")); // indent nicely
	WrappedCode += TEXT("\n}\n");
	WrappedCode += TEXT("#endif\n");


	// Define output file path (change as needed)
	FString FilePath = ShaderDir / TEXT("/MyCustomSDFs.ush");

	// Ensure directory exists
	FString Directory = FPaths::GetPath(FilePath);
	IFileManager::Get().MakeDirectory(*Directory, true);

	// Write to file
	if(FFileHelper::SaveStringToFile(WrappedCode, *FilePath))
	{
		UE_LOG(LogTemp, Log, TEXT("Shader code written to: %s"), *FilePath);
	}
	else
	{
		UE_LOG(LogTemp, Error, TEXT("Failed to write shader code to: %s"), *FilePath);
	}

	// include customSDF.ush
	ReplaceBetweenMarkers("// PSFCODEINCLUDECUSTOMSDFSTART", "// PSFCODEINCLUDECUSTOMSDFEND", "#include \"MyCustomSDFs.ush\"\n");


	// Modify evalScene
	ReplaceBetweenMarkers("// PSFCODEEVALCUSTOMSDFSTART", "// PSFCODEEVALCUSTOMSDFEND",	"else if (s.type == 99)\n"
																					"{\n"
																						"float dist = sdMyCustomSDF(probePoint, time);\n"
																						"return dist;\n"
																					"}\n");


	// Add void addCustomSDF(inout int index, MaterialParams material){} function to sdf_functions.ush
	ReplaceBetweenMarkers("// PSFCODEADDCUSTOMSDFSTART", "// PSFCODEADDCUSTOMSDFEND",	"void addCustomSDF(inout int index, MaterialParams material)\n"
																					"{\n"
																						"SDF newSDF;\n"

																						"newSDF.type = 99;\n"
																						"newSDF.material = material;\n"
																						"newSDF.rotation = computeRotationMatrix(normalize(float3(0.0, 1.0, 0.0)), 0 * PI / 180);\n"

																						"addSDF(index, newSDF);\n"

																					"}\n");


}

void FProceduralShaderFrameworkModule::ReplaceBetweenMarkers(const FString &StartMarker, const FString &EndMarker, const FString &Replacement) {
	FString FileContent;
	FString FilePath = ShaderDir / TEXT("/sdf_functions.ush");

	// Load file content
	if(!FFileHelper::LoadFileToString(FileContent, *FilePath))
	{
		UE_LOG(LogTemp, Error, TEXT("Failed to read file: %s"), *FilePath);
	}

	// Find marker positions
	int32 StartIndex = FileContent.Find(StartMarker, ESearchCase::IgnoreCase, ESearchDir::FromStart);
	int32 EndIndex = FileContent.Find(EndMarker, ESearchCase::IgnoreCase, ESearchDir::FromStart);

	if(StartIndex == INDEX_NONE || EndIndex == INDEX_NONE || EndIndex <= StartIndex)
	{
		UE_LOG(LogTemp, Error, TEXT("Could not find valid marker range in file."));
	}

	// Find the line ends after each marker
	int32 StartLineEnd = FileContent.Find(LINE_TERMINATOR, ESearchCase::IgnoreCase, ESearchDir::FromStart, StartIndex);
	int32 EndLineStart = EndIndex;

	// Extract parts
	FString Before = FileContent.Left(StartLineEnd + FCString::Strlen(LINE_TERMINATOR));
	FString After = FileContent.Mid(EndLineStart);

	FString NewContent = Before + Replacement + LINE_TERMINATOR + After;

	// Write back to file
	if(!FFileHelper::SaveStringToFile(NewContent, *FilePath))
	{
		UE_LOG(LogTemp, Error, TEXT("Failed to write file: %s"), *FilePath);
	}

	UE_LOG(LogTemp, Log, TEXT("Successfully updated file between markers."));
}


void FProceduralShaderFrameworkModule::GenerateMaterialFunction()
{
	FString AssetName = TEXT("AddCustomSDF");
	FString PackagePath = TEXT("/Game/SDF");
	FAssetToolsModule &AssetToolsModule = FAssetToolsModule::GetModule();


	// Try to load existing asset
	UPackage *ExistingPackage = FindPackage(nullptr, *(PackagePath / AssetName));
	if(ExistingPackage)
	{
		UObject *ExistingAsset = StaticFindObject(nullptr, ExistingPackage, *AssetName);
		if(ExistingAsset)
		{
			// Mark for delete
			TArray<UObject *> AssetsToDelete = {ExistingAsset};
			ObjectTools::DeleteObjectsUnchecked(AssetsToDelete);
			UE_LOG(LogTemp, Warning, TEXT("Existing asset '%s' was deleted."), *(PackagePath / AssetName));
		}
	}



	

	// Create the asset
	UMaterialFunctionFactoryNew *Factory = NewObject<UMaterialFunctionFactoryNew>();


	UObject* CreatedAsset = AssetToolsModule.Get().CreateAsset(
		AssetName, PackagePath, UMaterialFunction::StaticClass(), Factory);


	UMaterialFunction *MaterialFunction = Cast<UMaterialFunction>(CreatedAsset);

	if(!MaterialFunction)
	{
		UE_LOG(LogTemp, Error, TEXT("Failed to create Material Function."));
		return;
	}

	// Mark as transactional so we can undo/redo
	MaterialFunction->SetFlags(RF_Transactional);

	// Create nodes
	UMaterialExpressionFunctionInput *IndexInputNode = NewObject<UMaterialExpressionFunctionInput>(MaterialFunction, UMaterialExpressionFunctionInput::StaticClass(), NAME_None, RF_Transactional);
	UMaterialExpressionFunctionInput *MaterialInputNode = NewObject<UMaterialExpressionFunctionInput>(MaterialFunction, UMaterialExpressionFunctionInput::StaticClass(), NAME_None, RF_Transactional);


	UMaterialExpressionCustom *CustomNode = NewObject<UMaterialExpressionCustom>(MaterialFunction, UMaterialExpressionCustom::StaticClass(), NAME_None, RF_Transactional);
	UMaterialExpressionFunctionOutput *OutputNode = NewObject<UMaterialExpressionFunctionOutput>(MaterialFunction, UMaterialExpressionFunctionOutput::StaticClass(), NAME_None, RF_Transactional);

	UMaterialExpressionBreakMaterialAttributes *BreakMaterialNode = NewObject<UMaterialExpressionBreakMaterialAttributes>(MaterialFunction, UMaterialExpressionBreakMaterialAttributes::StaticClass(), NAME_None, RF_Transactional);

	// Configure Inputs
	IndexInputNode->InputName = TEXT("index");
	IndexInputNode->InputType = FunctionInput_Scalar;
	IndexInputNode->MaterialExpressionEditorX = -400;
	IndexInputNode->MaterialExpressionEditorY = 0;

	MaterialInputNode->InputName = TEXT("material");
	MaterialInputNode->InputType = FunctionInput_MaterialAttributes;
	MaterialInputNode->MaterialExpressionEditorX = -400;
	MaterialInputNode->MaterialExpressionEditorY = -200;


	FCustomInput baseColor, specularColor, specularStrength, shininess, roughness, metallic, rimPower, fakeSpecularColor, fakeSpecularPower, ior, refractionStrength, refractionTint;
	baseColor.InputName = TEXT("baseColor");
	specularColor.InputName = TEXT("specularColor");
	specularStrength.InputName = TEXT("specularStrength");
	shininess.InputName = TEXT("shininess");
	roughness.InputName = TEXT("roughness");
	metallic.InputName = TEXT("metallic");
	rimPower.InputName = TEXT("rimPower");
	fakeSpecularColor.InputName = TEXT("fakeSpecularColor");
	fakeSpecularPower.InputName = TEXT("fakeSpecularPower");
	ior.InputName = TEXT("ior");
	refractionStrength.InputName = TEXT("refractionStrength");
	refractionTint.InputName = TEXT("refractionTint");

	CustomNode->Inputs.Add(baseColor);
	CustomNode->Inputs.Add(specularColor);
	CustomNode->Inputs.Add(specularStrength);
	CustomNode->Inputs.Add(shininess);
	CustomNode->Inputs.Add(roughness);
	CustomNode->Inputs.Add(metallic);
	CustomNode->Inputs.Add(rimPower);
	CustomNode->Inputs.Add(fakeSpecularColor);
	CustomNode->Inputs.Add(fakeSpecularPower);
	CustomNode->Inputs.Add(ior);
	CustomNode->Inputs.Add(refractionStrength);
	CustomNode->Inputs.Add(refractionTint);

	// Configure Custom node
	CustomNode->Code = TEXT("float index = Index;\n"
		"MaterialParams mat;\n"
		"mat.baseColor = baseColor;\n"
		"mat.specularColor = specularColor;\n"
		"mat.specularStrength = specularStrength;\n"
		"mat.shininess = shininess;\n"
		"mat.roughness = roughness;\n"
		"mat.metallic = metallic;\n"
		"mat.rimPower = rimPower;\n"
		"mat.fakeSpecularColor = fakeSpecularColor;\n"
		"mat.fakeSpecularPower = fakeSpecularPower;\n"
		"mat.ior = ior;\n"
		"mat.refractionStrength = refractionStrength;\n"
		"mat.refractionTint = refractionTint;\n"
		"addCustomSDF(index, mat);\n"
		"return index;\n");  // your custom HLSL code
	CustomNode->OutputType = CMOT_Float1;

	CustomNode->IncludeFilePaths.Add("/ProceduralShaderFramework/procedural_shader.ush");
	CustomNode->IncludeFilePaths.Add("/ProceduralShaderFramework/MyCustomSDFs.ush");
	CustomNode->ShowCode = true;
	CustomNode->Inputs[0].InputName = "Index";

	CustomNode->MaterialExpressionEditorX = 400;
	CustomNode->MaterialExpressionEditorY = 0;

	// Connect input to custom input
	CustomNode->Inputs[0].Input.Connect(0, IndexInputNode); // index

	CustomNode->Inputs[1].Input.Connect(0, BreakMaterialNode); // basecolor -> basecolor
	CustomNode->Inputs[6].Input.Connect(1, BreakMaterialNode); // metallic -> metallic
	CustomNode->Inputs[3].Input.Connect(2, BreakMaterialNode); // Specular -> specularStrength
	CustomNode->Inputs[5].Input.Connect(3, BreakMaterialNode); // Roughness -> roughness
	CustomNode->Inputs[9].Input.Connect(4, BreakMaterialNode); // Anisotropy -> fakeSpecularPower
	CustomNode->Inputs[2].Input.Connect(5, BreakMaterialNode); // EmissiveColor -> SpecularColor
	CustomNode->Inputs[4].Input.Connect(6, BreakMaterialNode); // Opacity -> shininess
	CustomNode->Inputs[7].Input.Connect(7, BreakMaterialNode); // OpacityMask -> rimPower
	CustomNode->Inputs[8].Input.Connect(8, BreakMaterialNode); // Normal -> fakeSpecularColor
	CustomNode->Inputs[12].Input.Connect(9, BreakMaterialNode); // Tangent -> refractionTint
	CustomNode->Inputs[11].Input.Connect(13, BreakMaterialNode); // ClearCoatRoughness -> refractionStrength
	CustomNode->Inputs[10].Input.Connect(14, BreakMaterialNode); // AmbientOcclusion -> ior


	// Configure breakMaterialNode
	BreakMaterialNode->MaterialAttributes.Connect(0, MaterialInputNode);
	BreakMaterialNode->MaterialExpressionEditorX = 0;
	BreakMaterialNode->MaterialExpressionEditorY = 0;


	

	// Configure Output
	OutputNode->OutputName = TEXT("nextIndex");
	OutputNode->MaterialExpressionEditorX = 800;
	OutputNode->MaterialExpressionEditorY = 0;
	OutputNode->A.Connect(0, CustomNode);

	TArray<FFunctionExpressionInput> Inputs;
	TArray<FFunctionExpressionOutput> Outputs;
	MaterialFunction->GetInputsAndOutputs(Inputs, Outputs);


	FMaterialExpressionCollection Collection;
	Collection.Expressions = {
		IndexInputNode,
		CustomNode,
		OutputNode,
		MaterialInputNode,
		BreakMaterialNode
	};

	MaterialFunction->AssignExpressionCollection(Collection);
	
	// Compile and save
	MaterialFunction->PostEditChange();
	MaterialFunction->MarkPackageDirty();
	MaterialFunction->UpdateFromFunctionResource();
	UE_LOG(LogTemp, Log, TEXT("Material Function created and configured successfully."));


}

#undef LOCTEXT_NAMESPACE


	
IMPLEMENT_MODULE(FProceduralShaderFrameworkModule, ProceduralShaderFramework)
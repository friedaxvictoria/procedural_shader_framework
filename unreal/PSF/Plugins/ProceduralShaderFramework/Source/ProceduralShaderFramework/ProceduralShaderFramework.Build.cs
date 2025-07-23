// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;
using UnrealBuildTool.Rules;

public class ProceduralShaderFramework : ModuleRules
{
	public ProceduralShaderFramework(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = ModuleRules.PCHUsageMode.UseExplicitOrSharedPCHs;
		
		PublicIncludePaths.AddRange(
			new string[] {
				// ... add public include paths required here ...
			}
			);
				
		
		PrivateIncludePaths.AddRange(
			new string[] {
				// ... add other private include paths required here ...
            }
			);






        PublicDependencyModuleNames.AddRange(
			new string[]
			{
				"Core",
				"MaterialEditor",
                "EditorScriptingUtilities"
				// ... add other public dependencies that you statically link with here ...
			}
			);
			
		
		PrivateDependencyModuleNames.AddRange(
			new string[]
			{
				"CoreUObject",
				"Engine",
				"Slate",
				"SlateCore",
                "Projects",
				"RenderCore",
                "ShaderPreprocessor",
                "ShaderCompilerCommon",
				"MaterialShaderQualitySettings",
				"Renderer",
				"MaterialEditor",
                "ToolMenus",
                "EditorScriptingUtilities"
				// ... add private dependencies that you statically link with here ...	
			}
			);
		
		
		DynamicallyLoadedModuleNames.AddRange(
			new string[]
			{
				// ... add any modules that your module loads dynamically here ...
			}
			);

        // Add this if not already set
        if (Target.bBuildEditor == true)
        {
            PrivateDependencyModuleNames.Add("UnrealEd");
        }

        // Optional but recommended
        PublicDefinitions.Add("WITH_EDITOR=1");
    }
}

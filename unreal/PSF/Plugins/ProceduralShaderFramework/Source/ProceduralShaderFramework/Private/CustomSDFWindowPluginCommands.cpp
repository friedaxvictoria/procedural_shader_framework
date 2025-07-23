// Copyright Epic Games, Inc. All Rights Reserved.

#include "CustomSDFWindowPluginCommands.h"

#define LOCTEXT_NAMESPACE "FCustomSDFWindowPluginModule"

void FCustomSDFWindowPluginCommands::RegisterCommands()
{
	UI_COMMAND(OpenPluginWindow, "CustomSDFWindowPlugin", "Bring up CustomSDFWindowPlugin window", EUserInterfaceActionType::Button, FInputChord());
}

#undef LOCTEXT_NAMESPACE

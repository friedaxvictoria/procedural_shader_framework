// Copyright Epic Games, Inc. All Rights Reserved.

#pragma once

#include "Framework/Commands/Commands.h"
#include "CustomSDFWindowPluginStyle.h"

class FCustomSDFWindowPluginCommands : public TCommands<FCustomSDFWindowPluginCommands>
{
public:

	FCustomSDFWindowPluginCommands()
		: TCommands<FCustomSDFWindowPluginCommands>(TEXT("CustomSDFWindowPlugin"), NSLOCTEXT("Contexts", "CustomSDFWindowPlugin", "CustomSDFWindowPlugin Plugin"), NAME_None, FCustomSDFWindowPluginStyle::GetStyleSetName())
	{
	}

	// TCommands<> interface
	virtual void RegisterCommands() override;

public:
	TSharedPtr< FUICommandInfo > OpenPluginWindow;
};
// Fill out your copyright notice in the Description page of Project Settings.


#include "SCustomSDFWidget.h"
#include "SlateOptMacros.h"

BEGIN_SLATE_FUNCTION_BUILD_OPTIMIZATION
void SCustomSDFWidget::Construct(const FArguments& InArgs)
{
    SNew(SDockTab)
        .TabRole(ETabRole::NomadTab)
        [
            SNew(SVerticalBox)
                + SVerticalBox::Slot()
                .AutoHeight()
                [
                    SNew(SHorizontalBox)
                        + SHorizontalBox::Slot()
                        .VAlign(VAlign_Top)
                        [
                            SNew(STextBlock)
                                .Text(FText::FromString("Test Button"))
                        ]
                        + SHorizontalBox::Slot()
                        .VAlign(VAlign_Top)
                        [
                            SNew(SButton)
                                .Text(FText::FromString("Press Me"))
                        ]
                ]
            + SVerticalBox::Slot()
                .AutoHeight()
                [
                    SNew(SHorizontalBox)
                        + SHorizontalBox::Slot()
                        .VAlign(VAlign_Top)
                        [
                            SNew(STextBlock)
                                .Text(FText::FromString("Test Checkbox"))
                        ]
                        + SHorizontalBox::Slot()
                        .VAlign(VAlign_Top)
                        [
                            SNew(SCheckBox)
                        ]
                ]
        ];
}
END_SLATE_FUNCTION_BUILD_OPTIMIZATION

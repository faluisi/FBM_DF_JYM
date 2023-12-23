page 61503 FBM_DimValue
{
    Caption = 'Dim Value full';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Dimension Value";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Dimension Code"; rec."Dimension Code")
                {
                    ApplicationArea = All;
                }
                field("Code"; rec."Code")
                {
                    ApplicationArea = All;
                }
                field("Name"; rec."Name")
                {
                    ApplicationArea = All;
                }

            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
}
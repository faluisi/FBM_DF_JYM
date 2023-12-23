pageextension 61502 FBM_GLsetupExt_DF extends "General Ledger Setup"
{

    layout
    {
        addbefore(General)
        {
            field(permset; permset)
            {
                ApplicationArea = all;
                TableRelation = "Aggregate Permission Set"."Role ID";
                caption = 'Permission Set';

            }
            field(permaction; permaction)
            {
                ApplicationArea = all;
                caption = 'Action (0=delete; 1=add)';


            }

        }
    }
    actions
    {
        addlast(processing)
        {
            action("Data Migration")
            {
                Image = Database;
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    cu: codeunit FBM_Migration_DF;
                begin
                    cu.dataMigration();
                end;

            }
            action("Only Site")
            {
                Image = Database;
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    cu: codeunit FBM_Migration_DF;
                begin
                    cu.dataMigrationonlysite();
                end;

            }



        }

    }
    var
        permset: code[20];
        permaction: integer;
}
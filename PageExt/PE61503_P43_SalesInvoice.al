pageextension 61503 FBM_SalesInvExt_DF extends "Sales Invoice"
{
    layout
    {
        modify("Period Start")
        {
            Visible = false;


        }
        modify("Period Start_CO")
        {

            trigger
            OnAfterValidate()
            begin
                rec."Period Start" := rec."FBM_Period Start";
            end;

        }
        modify("Period End")
        {
            Visible = false;

        }
        modify("Period End_CO")
        {
            Visible = false;
            trigger
            OnAfterValidate()
            begin
                rec."Period End" := rec."FBM_Period End";
            end;
        }
        modify(Site)
        {
            Visible = false;

        }
        modify(Site_CO)
        {

            trigger
            OnAfterValidate()
            begin
                rec.Site := rec.FBM_Site;
            end;
        }
        modify("Contract Code")
        {
            Visible = false;

        }
        modify("Contract Code_CO")
        {

            trigger
            OnAfterValidate()
            begin
                rec."Contract Code" := rec."FBM_Contract Code";
            end;
        }
        modify("Billing Statement")
        {
            Visible = false;

        }
        modify("Billing Statement_CO")
        {

            trigger
            OnAfterValidate()
            begin
                rec."Billing Statement" := rec."FBM_Billing Statement";
            end;
        }


    }
}
pageextension 61509 FBM_SalesCRMExt_DF extends "Sales Credit Memo"
{
    layout
    {
        modify("Period Start")
        {
            Visible = false;


        }
        modify("FBM_Period Start")
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
        modify("FBM_Period End")
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
        modify(FBM_Site)
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
        modify("FBM_Contract Code")
        {

            trigger
            OnAfterValidate()
            begin
                rec."Contract Code" := rec."FBM_Contract Code";
            end;
        }



    }
}
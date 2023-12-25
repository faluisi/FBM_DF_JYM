pageextension 61511 FBM_SalesInvListExt_DF extends "Sales Invoice List"
{
    layout
    {
        modify("Billing Statement")
        {
            Visible = false;
        }

    }
}
pageextension 61512 FBM_PosdtedSCRMExt_DF extends "Posted Sales Credit Memo"
{
    layout
    {
        modify("Period Start")
        {
            Visible = false;
        }
        modify("Period End")
        {
            Visible = false;
        }
        modify("Contract Code")
        {
            Visible = false;
        }
        modify(Site)
        {
            Visible = false;
        }
    }
    actions
    {
        modify(ChangePeriodDate)
        {
            Visible = false;
        }

    }
}
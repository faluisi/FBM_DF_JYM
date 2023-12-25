pageextension 61508 FBM_PostedSInvExt_DF extends "Posted Sales Invoice"
{
    layout
    {
        modify("Contract Code")
        {
            Visible = false;
        }
        modify(Site)
        {
            Visible = false;
        }
        modify("Period Start")
        {
            Visible = false;
        }
        modify("Period End")
        {
            Visible = false;
        }

    }
}
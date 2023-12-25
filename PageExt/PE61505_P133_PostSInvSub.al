pageextension 61505 FBM_PostInvSubExt_DF extends "Posted Sales Invoice Subform"
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


    }
    actions
    {
        modify(ChangeGroup)
        {
            Visible = false;
        }



    }
}
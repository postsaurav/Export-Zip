pageextension 50101 "SDH Customer Card Ext" extends "Customer Card"
{
    actions
    {
        addlast("&Customer")
        {
            action(GenerateZip)
            {
                ApplicationArea = All;
                Caption = 'Generate Zip File';
                ToolTip = 'Generate Zip File';
                Image = ExportAttachment;
                trigger OnAction()
                var
                    ExportZip: Codeunit "SDH Export Zip File";
                begin
                    ExportZip.GetZipforOverdueInvocies(Rec);
                end;
            }
        }
    }
}
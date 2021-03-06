codeunit 50102 "SDH Export Zip File"
{

    procedure GetZipforOverdueInvocies(Cust: Record Customer)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DataCompression: Codeunit "Data Compression";
        ZipTempBlob: Codeunit "Temp Blob";
        ZipFileName: Text;
        ZipOutStream: OutStream;
        ZipInstream: InStream;
    begin
        IF NoOverDueInvoiceExist(Cust, CustLedgerEntry) then begin
            Message('No Overdue Invoices for customer %1', Cust."No.");
            exit;
        end;

        DataCompression.CreateZipArchive();

        GenerateInvoicePDF(CustLedgerEntry, DataCompression);

        ZipTempBlob.CreateOutStream(ZipOutStream);
        DataCompression.SaveZipArchive(ZipOutStream);
        DataCompression.CloseZipArchive();

        ZipTempBlob.CreateInStream(ZipInstream);
        ZipFileName := 'Attachment.zip';
        DownloadFromStream(ZipInstream, '', '', '', ZipFileName);
    end;

    local procedure NoOverDueInvoiceExist(Cust: Record Customer; Var CustLedgerEntry: Record "Cust. Ledger Entry"): Boolean
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Customer No.", Cust."No.");
        CustLedgerEntry.SetFilter("Remaining Amount", '<>0');
        CustLedgerEntry.SetFilter("Due Date", '<%1', WorkDate());
        Exit(CustLedgerEntry.IsEmpty);
    end;

    local procedure GenerateInvoicePDF(Var CustLedgerEntry: Record "Cust. Ledger Entry"; var DataCompression: Codeunit "Data Compression")
    var
        SalesInvoice: Record "Sales Invoice Header";
        TempBlob: Codeunit "Temp Blob";
        SalesInvRecRef: RecordRef;
        Istream: InStream;
        Ostream: OutStream;
        FileName: Text;
    begin
        If CustLedgerEntry.Findset() then
            repeat
                TempBlob.CreateOutStream(Ostream);
                SalesInvoice.SetFilter("No.", CustLedgerEntry."Document No.");
                SalesInvRecRef.GetTable(SalesInvoice);
                Report.SaveAs(Report::"Sales Invoice NA", '', ReportFormat::Pdf, Ostream, SalesInvRecRef);
                TempBlob.CreateInStream(Istream);
                FileName := CustLedgerEntry."Document No." + '.pdf';
                DataCompression.AddEntry(Istream, FileName);
            until (CustLedgerEntry.Next() = 0);
    end;
}
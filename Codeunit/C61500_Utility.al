codeunit 61502 FBM_Migration_DF
{
    Permissions = tabledata "Detailed Cust. Ledg. Entry" = rimd, tabledata "Cust. Ledger Entry" = rimd, tabledata "G/L Entry" = rimd, tabledata "Sales Invoice Header" = rimd, tabledata "Sales Invoice Line" = rimd, tabledata "Sales Cr.Memo Header" = rimd, tabledata "Sales Cr.Memo Line" = rimd, tabledata "Purch. Inv. Header" = rimd, tabledata "Purch. Inv. Line" = rimd, tabledata "Purch. Cr. Memo Hdr." = rimd, tabledata "Purch. Cr. Memo Line" = rimd, tabledata "Detailed Vendor Ledg. Entry" = rimd, tabledata "Vendor Ledger Entry" = rimd, tabledata "Item Ledger Entry" = rimd;

    var
        fa2: RECORD "Fixed Asset";
        window: Dialog;
        nrec: Integer;
        crec: integer;
        ntable: text[100];
        comp: record Company;
        Termsconditions_old: record TermsConditions;
        Termsconditions_new: record FBM_TermsConditions;
        customer: record Customer;
        fbmcust: record FBM_Customer;
        site_old: record "Customer-Site";
        site_new: record FBM_Site;
        cos: record "Cust-Op-Site";
        cos_new: record FBM_CustOpSite;
        compinfo: record "Company Information";
        custLE: record "Cust. Ledger Entry";
        detCustLE: record "Detailed Cust. Ledg. Entry";
        fa: record "Fixed Asset";
        GenJnlLine: record "Gen. Journal Line";
        glaccount: record "G/L Account";
        glentry: record "G/L Entry";
        sheader: record "Sales Header";
        sline: record "Sales Line";

        siheader: record "Sales Invoice Header";
        siline: record "Sales Invoice Line";
        scheader: record "Sales Cr.Memo Header";
        scline: record "Sales Cr.Memo Line";
        salessetup: record "Sales & Receivables Setup";
        usetup: record "User Setup";
        vendorle: record "Vendor Ledger Entry";
        detvendorle: record "Detailed Vendor Ledg. Entry";
        vendor: record Vendor;
        bankacc: record "Bank Account";
        itemle: record "Item Ledger Entry";
        SalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer";
        fasub: record "FA Subclass";
        country: Record "Country/Region";
        csite_new: record FBM_CustomerSite_C;
        csite: record "Customer-Site";


    procedure dataMigration()
    begin
        window.open('#1#######/#2#######/#3#######');
        fbmcust.DeleteAll();
        cos_new.DeleteAll();
        site_new.DeleteAll();
        if comp.FindFirst() then begin
            repeat
                compinfo.ChangeCompany(comp.Name);
                compinfo.get;
                if compinfo.FBM_EnMigr then begin
                    Termsconditions_old.ChangeCompany(comp.Name);
                    Termsconditions_new.ChangeCompany(comp.Name);
                    nrec := Termsconditions_old.Count;
                    ntable := Termsconditions_old.TableCaption;
                    crec := 0;
                    Termsconditions_new.DeleteAll();
                    if Termsconditions_old.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            Termsconditions_new.Init();
                            Termsconditions_new.Country := Termsconditions_old.Country;
                            Termsconditions_new."Line No." := Termsconditions_old."Line No.";
                            Termsconditions_new."Terms Conditions" := Termsconditions_old."Terms Conditions";
                            //Termsconditions_new.DocType := Termsconditions_old.DocType;
                            Termsconditions_new.Insert();
                        until Termsconditions_old.Next() = 0;
                    customer.ChangeCompany(comp.Name);
                    nrec := customer.count;
                    crec := 0;
                    ntable := customer.TableCaption;
                    if customer.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            if (not fbmcust.get(customer."No. 2", 0, true)) and (customer."No. 2" <> '') then begin
                                fbmcust.init;
                                fbmcust.TransferFields(customer, false);
                                fbmcust.FBM_Group := customer.Group;
                                fbmcust.FBM_SubGroup := customer.SubGroup;
                                fbmcust."FBM_Separate Halls Inv." := customer."Separate Halls Inv.";
                                fbmcust."FBM_Customer Since" := customer."Customer Since";
                                fbmcust."FBM_Payment Bank Code" := customer."Payment Bank Code";
                                //fbmcust."FBM_Payment Bank Code2" := customer."Payment Bank Code2";

                                fbmcust."Valid From" := Today;
                                fbmcust."Valid To" := DMY2Date(31, 12, 2999);
                                fbmcust."Record Owner" := UserId;
                                fbmcust.ActiveRec := true;
                                fbmcust."No." := customer."No. 2";
                                fbmcust.Insert();


                            end;
                            customer.FBM_Group := customer.Group;
                            customer.FBM_SubGroup := customer.SubGroup;
                            customer."FBM_Payment Bank Code" := customer."Payment Bank Code";
                            //customer."FBM_Payment Bank Code2" := customer."Payment Bank Code2";
                            customer."FBM_Separate Halls Inv." := customer."Separate Halls Inv.";
                            customer."FBM_Customer Since" := customer."Customer Since";
                            customer.FBM_GrCode := customer."No. 2";
                            customer."FBM_Name 3" := customer.Name;
                            customer.Modify();
                        until customer.Next() = 0;
                    csite.ChangeCompany(comp.Name);
                    csite_new.ChangeCompany(comp.Name);
                    cos.ChangeCompany(comp.Name);
                    csite_new.DeleteAll();
                    nrec := csite.Count;
                    crec := 0;
                    ntable := csite_new.TableCaption;
                    if csite.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            csite_new.Init();
                            csite_new."Customer No." := csite."Customer No.";
                            csite_new."Site Code" := csite."Site Code";
                            //csite_new.Contact := csite.Contact;
                            csite_new."Contract Code" := csite."Contract Code";
                            //csite_new."Contract Code2" := csite."Contract Code2";
                            cos.SetRange("Customer No.", csite."Customer No.");
                            cos.SetRange("Site Code", csite."Site Code");
                            if cos.FindFirst() then
                                csite_new.SiteGrCode := cos."Site Code 2";
                            csite_new.Insert();
                        until csite.Next() = 0;

                    country.ChangeCompany((comp.Name));
                    customer.ChangeCompany((comp.Name));
                    cos.Reset();
                    nrec := cos.Count;
                    crec := 0;
                    ntable := cos_new.TableCaption;
                    cos.Reset();
                    customer.Reset();

                    if COS.FindFirst() then BEGIN
                        nrec := cos.count;
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            cos_new.Init();
                            IF customer.Get(cos."Customer No.") THEN begin
                                if customer."No. 2" <> '' then begin
                                    cos_new."Customer No." := customer."No. 2";
                                    cos_new."Cust Loc Code" := customer."No.";
                                end
                                else begin
                                    cos_new."Customer No." := compinfo."Custom System Indicator Text" + customer."No.";
                                end;
                                if customer."No. 2" <> '' then begin
                                    cos_new."Operator No." := customer."No. 2";
                                    cos_new."Op Loc Code" := customer."No.";
                                end
                                else begin
                                    cos_new."Operator No." := compinfo."Custom System Indicator Text" + customer."No.";
                                end;
                            end;

                            if cos."Site Code 2" <> '' then
                                cos_new."Site Code" := cos."Site Code 2"
                            else
                                cos_new."Site Code" := compinfo."Custom System Indicator Text" + cos."Site Code";
                            cos_new."Site Loc Code" := cos."Site Code";
                            if (customer."Country/Region Code" = 'PH') and (UpperCase(comp.Name) = 'FBM LTD') then
                                cos_new.IsActive := false else
                                cos_new.IsActive := true;
                            cos_new."Valid From" := Today;
                            cos_new."Valid To" := DMY2Date(31, 12, 2999);
                            cos_new."Record Owner" := UserId;
                            IF customer.Get(cos."Customer No.") THEN
                                if country.get(customer."Country/Region Code") then
                                    cos_new.Subsidiary := compinfo.FBM_FALessee + ' ' + country.FBM_Country3;

                            if cos_new.Insert() then begin
                            end;
                        until cos.Next() = 0;
                    END;
                    site_old.ChangeCompany(comp.Name);

                    crec := 0;
                    ntable := site_new.TableCaption;
                    cos.Reset();

                    if site_old.FindFirst() then BEGIN
                        nrec := site_old.count;
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            cos.SetRange("Site Code", site_old."Site Code");
                            if cos.FindFirst() and not site_new.get(cos."Site Code 2") then begin
                                site_new.Init();
                                if cos."Site Code 2" <> '' then
                                    site_new."Site Code" := cos."Site Code 2"
                                else
                                    site_new."Site Code" := compinfo."Custom System Indicator Text" + cos."Site Code";

                                site_new."Site Name" := site_old."Site Name";
                                site_new."Site Name 2" := site_old."Site Name";
                                site_new.Address := site_old.Address;
                                site_new."Address 2" := site_old."Address 2";
                                site_new.City := site_old.City;
                                site_new."Post Code" := site_old."Post Code";
                                site_new."Country/Region Code" := site_old."Country/Region Code";
                                site_new.Indent := site_old.Indent;
                                // site_new."Contract Code" := site_old."Contract Code";
                                // site_new."Contract Code2" := site_old."Contract Code2";
                                site_new."Vat Number" := cos."Vat Number";
                                //site_new.Status := site_new.Status::" ";

                                site_new."Valid From" := Today;
                                site_new."Valid To" := DMY2Date(31, 12, 2999);
                                site_new."Record Owner" := UserId;
                                site_new.ActiveRec := true;
                                site_new.Insert()
                            end;
                        until site_old.Next() = 0;
                    end;
                    compinfo.ChangeCompany(comp.Name);
                    nrec := compinfo.count;
                    crec := 0;
                    ntable := compinfo.TableCaption;
                    if compinfo.FindFirst() then begin
                        crec += 1;
                        winupdate(nrec, crec, comp.Name, ntable);
                        compinfo."FBM_TINNumber" := compinfo."TIN Number";
                        compinfo.FBM_EnSiteWS := compinfo.FBM_EnSiteWS;
                        compinfo.FBM_EnSpin := compinfo.FBM_EnSpin;
                        compinfo.FBM_EnWS := compinfo.FBM_EnWS;
                        compinfo.Modify();
                    end;
                    custLE.ChangeCompany(comp.Name);
                    nrec := custLE.count;
                    crec := 0;
                    ntable := custLE.TableCaption;
                    if custLE.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            custLE."FBM_Period End" := custLE."Period End";
                            custLE."FBM_Period Start" := custLE."Period Start";
                            //custLE.FBM_Segment := custLE.Segment;
                            cos.Reset();
                            cos.SetRange("Customer No.", custLE."Customer No.");
                            //cos.SetRange("Site Code", custLE.Site);
                            if cos.FindFirst() then
                                custLE.FBM_Site := cos."Site Code 2";
                            if (siheader.get(custLE."Document No.")) or (scheader.get(custLE."Document No.")) then begin
                                SalesCrMemoEntityBuffer.SetRange("Cust. Ledger Entry No.", custLE."Entry No.");
                                SalesCrMemoEntityBuffer.SetRange(Posted, true);
                                if not SalesCrMemoEntityBuffer.IsEmpty then
                                    if scheader.get(SalesCrMemoEntityBuffer."No.") then
                                        custLE.Modify();
                            end;
                        until custLE.Next() = 0;
                    detcustLE.ChangeCompany(comp.Name);
                    nrec := detCustLE.count;
                    crec := 0;
                    ntable := detCustLE.TableCaption;
                    if detcustLE.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            detcustLE."FBM_Period End" := detcustLE."Period End";
                            detcustLE."FBM_Period Start" := detcustLE."Period Start";
                            //detCustLE.FBM_Segment := detCustLE.Segment;
                            cos.Reset();
                            cos.SetRange("Customer No.", detCustLE."Customer No.");
                            // cos.SetRange("Site Code", detCustLE.Site);
                            // if cos.FindFirst() then
                            //     detCustLE.FBM_Site := cos."Site Code 2";
                            detcustLE.Modify();
                        until detcustLE.Next() = 0;
                    fa.ChangeCompany(comp.Name);
                    compinfo.ChangeCompany(comp.Name);
                    compinfo.get;
                    /* nrec := fa.count;
                    crec := 0;
                    ntable := fa.TableCaption;
                    if fa.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            //fa."FBM_Date Prepared" := fa."Date Prepared";
                            //fa."FBM_Fa Posting Group Depr" := fa."Fa Posting Group Depr";
                            //fa.FBM_Group := fa.Group;
                            // fa.FBM_Hall := fa.Hall;
                            // fa."FBM_Hall Status" := fa."Hall Status";
                            // fa.FBM_Location := fa.Location;
                            // fa."FBM_Operator Name" := fa."Operator Name";
                            // fa."FBM_Business Name" := fa."Business Name";
                            fa.FBM_Lessee := format(fa.Lessee);
                            fa.FBM_Brand := fa.Brand;
                            fa2.ChangeCompany('Drako Ltd');
                            if (UpperCase(comp.Name) = 'FBM LTD') then begin
                                fa2.Reset();
                                fa2.SetRange("Serial No.", fa."Serial No.");
                                if fa2.IsEmpty then
                                    fa.IsActive := true
                                else
                                    fa.IsActive := false;
                                if fa.FBM_Brand = fa.FBM_Brand::DINGO then
                                    fa.FBM_Lessee := 'DPH'
                                else
                                    if fa.FBM_Brand = fa.FBM_Brand::FBM then
                                        fa.FBM_Lessee := 'NPH';



                            end
                            else begin
                                fa.FBM_Lessee := compinfo.FBM_FALessee;
                                fa.IsActive := true;
                                if comp.name = 'Drako Ltd' then
                                    if fa.FBM_Brand = fa.FBM_Brand::DINGO then
                                        fa.FBM_Lessee := 'DPH'
                                    else
                                        if fa.FBM_Brand = fa.FBM_Brand::FBM then
                                            fa.FBM_Lessee := 'NPH';

                            end;
                            //fa.FBM_Status := fa.Status;
                            cos_new.SetRange("Site Code", fa.FBM_Site);

                            if cos.findfirst then begin
                                if customer.get(cos."Customer No.") then begin
                                    country.get(customer."Country/Region Code");
                                    fa.FBM_Subsidiary := format(fa.FBM_Lessee) + ' ' + country.FBM_Country3;
                                end;
                            end

                            else begin
                                country.get(compinfo."Country/Region Code");
                                fa.FBM_Subsidiary := compinfo.FBM_FALessee + ' ' + country.FBM_Country3;
                            end;
                            fa.modify;
                        until fa.Next() = 0; */
                    fasub.ChangeCompany(comp.Name);
                    nrec := fasub.count;
                    crec := 0;
                    ntable := fasub.TableCaption;
                    if fasub.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            //fasub.FBM_EGM := fasub.EGM;
                            fasub.Modify();
                        until fasub.Next() = 0;
                    GenJnlLine.ChangeCompany(comp.Name);
                    nrec := GenJnlLine.count;
                    crec := 0;
                    ntable := GenJnlLine.TableCaption;
                    if GenJnlLine.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            GenJnlLine."FBM_Period Start" := GenJnlLine."Period Start";
                            GenJnlLine."FBM_Period End" := GenJnlLine."Period End";
                            // GenJnlLine.FBM_Segment := GenJnlLine.Segment;
                            cos.Reset();

                            // cos.SetRange("Site Code", GenJnlLine.Site);
                            // if cos.FindFirst() then
                            //     GenJnlLine.FBM_Site := cos."Site Code 2";
                            GenJnlLine.Modify();
                        until GenJnlLine.Next() = 0;
                    glaccount.ChangeCompany(comp.Name);
                    nrec := glaccount.count;
                    crec := 0;
                    ntable := glaccount.TableCaption;
                    if glaccount.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            glaccount."FBM_Periods Required" := glaccount."Periods Required";
                            glaccount.Modify();
                        until glaccount.Next() = 0;
                    glentry.ChangeCompany(comp.Name);
                    nrec := glentry.count;
                    crec := 0;
                    ntable := glentry.TableCaption;
                    if glentry.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            glentry."FBM_Period Start" := glentry."Period Start";
                            glentry."FBM_Period End" := glentry."Period End";
                            //glentry.FBM_Segment := glentry.Segment;
                            cos.Reset();
                            // cos.SetRange("Site Code", glentry.Site);
                            // if cos.FindFirst() then
                            //     GenJnlLine.FBM_Site := cos."Site Code 2";
                            glentry.Modify();
                        until glentry.Next() = 0;
                    sheader.ChangeCompany(comp.Name);
                    nrec := sheader.count;
                    crec := 0;
                    ntable := sheader.TableCaption;
                    if sheader.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            sheader."FBM_Billing Statement" := sheader."Billing Statement";
                            sheader."FBM_Contract Code" := sheader."Contract Code";
                            sheader.FBM_Site := sheader.Site;
                            sheader."FBM_Period Start" := sheader."Period Start";
                            sheader."FBM_Period End" := sheader."Period End";
                            // sheader.FBM_Segment := sheader.Segment;
                            // sheader.FBM_LocalCurrAmt := sheader.LocalCurrAmt;
                            // sheader.FBM_Currency2 := sheader.Currency2;
                            // sheader.FBM_Signature_pic := sheader.signature_pic;
                            sheader."FBM_Cust Payment Bank Name" := sheader."Customer Payment Bank Name";
                            // sheader."FBM_Cust Payment Bank Name2" := sheader."Customer Payment Bank Name2";

                            sheader.Modify();
                        until sheader.Next() = 0;
                    sline.ChangeCompany(comp.Name);
                    nrec := sline.count;
                    crec := 0;
                    ntable := sline.TableCaption;
                    if sline.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            sline.FBM_IsPeriodEnabled := sline.IsPeriodEnabled;
                            //sline.FBM_Site := sline.Site;
                            sline."FBM_Period Start" := sline."Period Start";
                            sline."FBM_Period End" := sline."Period End";
                            sline.Modify();
                        until sline.Next() = 0;
                    siheader.ChangeCompany(comp.Name);
                    nrec := siheader.count;
                    crec := 0;
                    ntable := siheader.TableCaption;
                    if siheader.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            siheader."FBM_Billing Statement" := siheader."Billing Statement";
                            siheader."FBM_Contract Code" := siheader."Contract Code";
                            siheader.FBM_Site := siheader.Site;
                            siheader."FBM_Period Start" := siheader."Period Start";
                            siheader."FBM_Period End" := siheader."Period End";
                            // siheader.FBM_Segment := siheader.Segment;
                            // siheader.FBM_LocalCurrAmt := siheader.LocalCurrAmt;
                            // siheader.FBM_Currency2 := siheader.Currency2;
                            // siheader.FBM_Signature_pic := siheader.signature_pic;
                            // siheader."FBM_Cust Payment Bank Name" := siheader."Customer Payment Bank Name";
                            // siheader."FBM_Cust Payment Bank Name2" := siheader."Customer Payment Bank Name2";
                            siheader.Modify();
                        until siheader.Next() = 0;
                    siline.ChangeCompany(comp.Name);
                    nrec := siline.count;
                    crec := 0;
                    ntable := siline.TableCaption;
                    if siline.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            // siline.FBM_Site := siline.Site;
                            siline."FBM_Period Start" := siline."Period Start";
                            siline."FBM_Period End" := siline."Period End";
                            siline.Modify();
                        until siline.Next() = 0;
                    scheader.ChangeCompany(comp.Name);
                    nrec := scheader.count;
                    crec := 0;
                    ntable := scheader.TableCaption;
                    if scheader.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            scheader."FBM_Contract Code" := scheader."Contract Code";
                            scheader.FBM_Site := scheader.Site;
                            scheader."FBM_Period Start" := scheader."Period Start";
                            scheader."FBM_Period End" := scheader."Period End";
                            //scheader.FBM_Segment := scheader.Segment;
                            scheader.Modify();
                        until scheader.Next() = 0;
                    scline.ChangeCompany(comp.Name);
                    nrec := scline.count;
                    crec := 0;
                    ntable := scline.TableCaption;
                    if scline.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            //scline.FBM_Site := scline.Site;
                            scline."FBM_Period Start" := scline."Period Start";
                            scline."FBM_Period End" := scline."Period End";
                            scline.Modify();
                        until scline.Next() = 0;
                    salessetup.ChangeCompany();
                    nrec := salessetup.count;
                    crec := 0;
                    ntable := salessetup.TableCaption;
                    if salessetup.Get() then begin
                        crec += 1;
                        winupdate(nrec, crec, comp.Name, ntable);
                        salessetup."FBM_Show Hall Invoice Warning" := salessetup."Show Hall Invoice Warning";
                        salessetup.Modify();
                    end;
                    usetup.ChangeCompany(comp.Name);
                    nrec := usetup.count;
                    crec := 0;
                    ntable := usetup.TableCaption;
                    if usetup.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            usetup."FBM_See LCY in Journals" := usetup."See LCY in Journals";
                            //usetup."FBM_Approve Finance" := usetup."Approve Finance";
                            usetup."FBM_Item Filter" := usetup."Item Filter";
                            usetup."FBM_Bank Filter" := usetup."Bank Filter";
                            usetup.Modify();
                        until usetup.Next() = 0;
                    vendorle.ChangeCompany(comp.Name);
                    nrec := vendorle.count;
                    crec := 0;
                    ntable := vendorle.TableCaption;
                    if vendorle.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            // vendorle.FBM_approved := vendorle.approved;
                            // vendorle."FBM_approved date" := vendorle."approved date";
                            // vendorle."FBM_approved user" := vendorle."approved user";
                            // vendorle."FBM_Approver Comment" := vendorle."Approver Comment";

                            //vendorle."FBM_Default Bank Account" := vendorle."Default Bank Account";
                            vendorle.Modify();
                        until vendorle.Next() = 0;
                    detvendorle.ChangeCompany(comp.Name);
                    nrec := detvendorle.count;
                    crec := 0;
                    ntable := detvendorle.TableCaption;
                    if detvendorle.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            //detvendorle."FBM_Default Bank Account" := detvendorle."Default Bank Account";
                            //detvendorle.FBM_approved := detvendorle.approved;
                            //detvendorle.FBM_open := detvendorle.open;
                            detvendorle.Modify();
                        until detvendorle.Next() = 0;
                    vendor.ChangeCompany(comp.Name);
                    nrec := vendor.count;
                    crec := 0;
                    ntable := vendor.TableCaption;
                    if vendor.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            // vendor."FBM_Default Bank Account" := vendor."Default Bank Account";
                            // vendor."FBM_Print Name on Check" := vendor."Print Name on Check";
                            vendor.Modify();
                        until vendor.Next() = 0;
                    bankacc.ChangeCompany(comp.Name);
                    nrec := bankacc.count;
                    crec := 0;
                    ntable := bankacc.TableCaption;
                    if bankacc.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);

                            bankacc.Modify();
                        until bankacc.Next() = 0;
                    itemle.ChangeCompany(comp.Name);
                    nrec := itemle.count;
                    crec := 0;
                    ntable := itemle.TableCaption;
                    if itemle.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            //itemle."FBM_Document No Value Entry_FF" := itemle."Document No Value Entry";
                            itemle.Modify();
                        until itemle.Next() = 0;
                    compinfo.ChangeCompany(comp.Name);
                    nrec := compinfo.count;
                    crec := 0;
                    ntable := compinfo.TableCaption;
                    if compinfo.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            compinfo.FBM_CustIsOp := compinfo."Customer Is Operator";
                            // compinfo.FBM_EnAppr := compinfo.FBM_EnableAppr;
                            // compinfo.FBM_EnSiteWS := compinfo.FBM_EnableSiteWS;
                            // compinfo.FBM_EnSpin := compinfo.FBM_EnableSpin;
                            // compinfo.FBM_EnWS := compinfo.FBM_EnableSpin;
                            compinfo.Modify();
                        until compinfo.Next() = 0;
                end;


            until comp.Next() = 0;

            window.Close();
        end;
    end;

    procedure dataMigrationonlysite()


    begin
        window.open('#1#######/#2#######/#3#######');
        fbmcust.DeleteAll();
        cos_new.DeleteAll();
        site_new.DeleteAll();
        if comp.FindFirst() then begin
            repeat
                compinfo.ChangeCompany(comp.Name);
                compinfo.get;
                if compinfo.FBM_ENMigr then begin
                    Termsconditions_old.ChangeCompany(comp.Name);
                    Termsconditions_new.ChangeCompany(comp.Name);
                    nrec := Termsconditions_old.Count;
                    ntable := Termsconditions_old.TableCaption;
                    crec := 0;
                    Termsconditions_new.DeleteAll();
                    if Termsconditions_old.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            Termsconditions_new.Init();
                            Termsconditions_new.Country := Termsconditions_old.Country;
                            Termsconditions_new."Line No." := Termsconditions_old."Line No.";
                            Termsconditions_new."Terms Conditions" := Termsconditions_old."Terms Conditions";
                            // Termsconditions_new.DocType := Termsconditions_old.DocType;
                            Termsconditions_new.Insert();
                        until Termsconditions_old.Next() = 0;
                    customer.ChangeCompany(comp.Name);
                    nrec := customer.count;
                    crec := 0;
                    ntable := customer.TableCaption;
                    if customer.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            if not fbmcust.get(customer."No. 2", 0) then begin
                                fbmcust.init;
                                fbmcust.TransferFields(customer, false);
                                fbmcust.FBM_Group := customer.Group;
                                fbmcust.FBM_SubGroup := customer.SubGroup;
                                fbmcust."FBM_Separate Halls Inv." := customer."Separate Halls Inv.";
                                fbmcust."FBM_Customer Since" := customer."Customer Since";
                                fbmcust."FBM_Payment Bank Code" := customer."Payment Bank Code";
                                // fbmcust."FBM_Payment Bank Code2" := customer."Payment Bank Code2";

                                fbmcust."Valid From" := Today;
                                fbmcust."Valid To" := DMY2Date(31, 12, 2999);
                                fbmcust."Record Owner" := UserId;
                                fbmcust.ActiveRec := true;
                                fbmcust."No." := customer."No. 2";
                                fbmcust.Insert();

                            end;
                            customer.FBM_Group := customer.Group;
                            customer.FBM_SubGroup := customer.SubGroup;
                            customer."FBM_Payment Bank Code" := customer."Payment Bank Code";
                            //customer."FBM_Payment Bank Code2" := customer."Payment Bank Code2";
                            customer."FBM_Separate Halls Inv." := customer."Separate Halls Inv.";
                            customer."FBM_Customer Since" := customer."Customer Since";
                            customer.FBM_GrCode := customer."No. 2";
                            customer.Modify();
                        until customer.Next() = 0;
                    csite.ChangeCompany(comp.Name);
                    csite_new.ChangeCompany(comp.Name);
                    cos.ChangeCompany(comp.Name);
                    csite_new.DeleteAll();
                    nrec := csite.Count;
                    crec := 0;
                    ntable := csite_new.TableCaption;
                    if csite.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            csite_new.Init();
                            csite_new."Customer No." := csite."Customer No.";
                            csite_new."Site Code" := csite."Site Code";

                            // csite_new.Contact := csite.Contact;
                            csite_new."Contract Code" := csite."Contract Code";
                            //csite_new."Contract Code2" := csite."Contract Code2";
                            cos.SetRange("Customer No.", csite."Customer No.");
                            cos.SetRange("Site Code", csite."Site Code");
                            if cos.FindFirst() then
                                csite_new.SiteGrCode := cos."Site Code 2";
                            csite_new.Insert();
                        until csite.Next() = 0;


                    country.ChangeCompany((comp.Name));
                    customer.ChangeCompany((comp.Name));
                    cos.Reset();
                    nrec := cos.Count;
                    crec := 0;
                    ntable := cos_new.TableCaption;
                    cos.Reset();
                    customer.Reset();

                    if COS.FindFirst() then BEGIN
                        nrec := cos.count;
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            cos_new.Init();
                            IF customer.Get(cos."Customer No.") THEN begin
                                if customer."No. 2" <> '' then begin
                                    cos_new."Customer No." := customer."No. 2";
                                    cos_new."Cust Loc Code" := customer."No.";
                                end
                                else begin
                                    cos_new."Customer No." := compinfo."Custom System Indicator Text" + customer."No.";
                                end;
                                if customer."No. 2" <> '' then begin
                                    cos_new."Operator No." := customer."No. 2";
                                    cos_new."Op Loc Code" := customer."No.";
                                end
                                else begin
                                    cos_new."Operator No." := compinfo."Custom System Indicator Text" + customer."No.";
                                end;
                            end;


                            if cos."Site Code 2" <> '' then
                                cos_new."Site Code" := cos."Site Code 2"
                            else
                                cos_new."Site Code" := compinfo."Custom System Indicator Text" + cos."Site Code";
                            cos_new."Site Loc Code" := cos."Site Code";
                            if (customer."Country/Region Code" = 'PH') and (UpperCase(comp.Name) = 'FBM LTD') then
                                cos_new.IsActive := false else
                                cos_new.IsActive := true;
                            cos_new."Valid From" := Today;
                            cos_new."Valid To" := DMY2Date(31, 12, 2999);
                            cos_new."Record Owner" := UserId;
                            IF customer.Get(cos."Customer No.") THEN
                                if country.get(customer."Country/Region Code") then
                                    cos_new.Subsidiary := compinfo.FBM_FALessee + ' ' + country.FBM_Country3;

                            if cos_new.Insert() then begin
                            end;
                        until cos.Next() = 0;
                    END;


                    site_old.ChangeCompany(comp.Name);

                    crec := 0;
                    ntable := site_new.TableCaption;
                    cos.Reset();

                    if site_old.FindFirst() then BEGIN
                        nrec := site_old.count;
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            cos.SetRange("Site Code", site_old."Site Code");
                            if cos.FindFirst() and not site_new.get(cos."Site Code 2") then begin
                                site_new.Init();
                                if cos."Site Code 2" <> '' then
                                    site_new."Site Code" := cos."Site Code 2"
                                else
                                    site_new."Site Code" := compinfo."Custom System Indicator Text" + cos."Site Code";

                                site_new."Site Name" := site_old."Site Name";
                                site_new.Address := site_old.Address;
                                site_new."Address 2" := site_old."Address 2";
                                site_new.City := site_old.City;
                                site_new."Post Code" := site_old."Post Code";
                                site_new."Country/Region Code" := site_old."Country/Region Code";
                                site_new.Indent := site_old.Indent;
                                // site_new."Contract Code" := site_old."Contract Code";
                                // site_new."Contract Code2" := site_old."Contract Code2";
                                site_new."Vat Number" := cos."Vat Number";
                                //site_new.Status := site_new.Status::" ";


                                site_new."Valid From" := Today;
                                site_new."Valid To" := DMY2Date(31, 12, 2999);
                                site_new."Record Owner" := UserId;
                                site_new.ActiveRec := true;
                                site_new.Insert()
                            end;
                        until site_old.Next() = 0;
                    end;
                    fa.ChangeCompany(comp.Name);
                    compinfo.ChangeCompany(comp.Name);
                    compinfo.get;
                    /*  nrec := fa.count;
                     crec := 0;
                     ntable := fa.TableCaption;
                     if fa.FindFirst() then
                         repeat
                             crec += 1;
                             winupdate(nrec, crec, comp.Name, ntable);
                             //fa."FBM_Date Prepared" := fa."Date Prepared";
                             //fa."FBM_Fa Posting Group Depr" := fa."Fa Posting Group Depr";
                             //fa.FBM_Group := fa.Group;
                             // fa.FBM_Hall := fa.Hall;
                             // fa."FBM_Hall Status" := fa."Hall Status";
                             // fa.FBM_Location := fa.Location;
                             // fa."FBM_Operator Name" := fa."Operator Name";
                             // fa."FBM_Business Name" := fa."Business Name";
                             fa.FBM_Lessee := format(fa.Lessee);
                             fa.FBM_Brand := fa.Brand;
                             fa2.ChangeCompany('Drako Ltd');
                             if (UpperCase(comp.Name) = 'FBM LTD') then begin
                                 fa2.Reset();
                                 fa2.SetRange("Serial No.", fa."Serial No.");
                                 if fa2.IsEmpty then
                                     fa.IsActive := true
                                 else
                                     fa.IsActive := false;
                                 if fa.FBM_Brand = fa.FBM_Brand::DINGO then
                                     fa.FBM_Lessee := 'DPH'
                                 else
                                     if fa.FBM_Brand = fa.FBM_Brand::FBM then
                                         fa.FBM_Lessee := 'NPH';



                             end
                             else begin
                                 fa.FBM_Lessee := compinfo.FBM_FALessee;
                                 fa.IsActive := true;
                                 if comp.name = 'Drako Ltd' then
                                     if fa.FBM_Brand = fa.FBM_Brand::DINGO then
                                         fa.FBM_Lessee := 'DPH'
                                     else
                                         if fa.FBM_Brand = fa.FBM_Brand::FBM then
                                             fa.FBM_Lessee := 'NPH';

                             end;
                             //fa.FBM_Status := fa.Status;
                             cos_new.SetRange("Site Code", fa.FBM_Site);

                             if cos.findfirst then begin
                                 if customer.get(cos."Customer No.") then begin
                                     country.get(customer."Country/Region Code");
                                     fa.FBM_Subsidiary := format(fa.FBM_Lessee) + ' ' + country.FBM_Country3;
                                 end;
                             end

                             else begin
                                 country.get(compinfo."Country/Region Code");
                                 fa.FBM_Subsidiary := compinfo.FBM_FALessee + ' ' + country.FBM_Country3;
                             end;
                             fa.modify;
                         until fa.Next() = 0;*/


                END;

            until comp.Next() = 0;
        end;
        window.Close();
    end;

    local procedure winupdate(NoOfRecs: integer;
CurrRec: integer;
ntable: text[100];
compname: text[100])
    begin
        window.Update(1, compname);
        window.Update(2, ntable);
        if NoOfRecs > 0 then
            IF NoOfRecs <= 100 THEN
                Window.UPDATE(3, (CurrRec / NoOfRecs * 10000) DIV 1)
            ELSE
                IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                    Window.UPDATE(3, (CurrRec / NoOfRecs * 10000) DIV 1);

    end;

    local procedure WSupdateFA()
    buffer: record FBM_WSBuffer;
    begin
        buffer.SetRange(F01, 'FA');

    end;
}
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <Windows.h>
#include <atlcomcli.h>
#include <oaidl.h>
#include <ShlObj.h>
#include <ShlDisp.h>
#include <ExDisp.h>
#include <servprov.h>

#include <array>
#include <vector>
#include <string>
#include <iostream>
#include <functional>

static std::unique_ptr<TYPEATTR, std::function<void(TYPEATTR*)>> GetTypeAttr(ITypeInfo* ti) {
    HRESULT hr;
    TYPEATTR* p;
    hr = ti->GetTypeAttr(&p);
    ATLENSURE_SUCCEEDED(hr);
    auto deleter = [ti](TYPEATTR* p) {ti->ReleaseTypeAttr(p); };
    return { p, deleter };
}

static std::unique_ptr<FUNCDESC, std::function<void(FUNCDESC*)>> GetFuncDesc(ITypeInfo* ti, UINT index) {
    HRESULT hr;
    FUNCDESC* p;
    hr = ti->GetFuncDesc(index, &p);
    ATLENSURE_SUCCEEDED(hr);
    auto deleter = [ti](FUNCDESC* p) {ti->ReleaseFuncDesc(p); };
    return { p, deleter };
}

static std::unique_ptr<VARDESC, std::function<void(VARDESC*)>> GetVarDesc(ITypeInfo* ti, UINT index) {
    HRESULT hr;
    VARDESC* p;
    hr = ti->GetVarDesc(index, &p);
    ATLENSURE_SUCCEEDED(hr);
    auto deleter = [ti](VARDESC* p) {ti->ReleaseVarDesc(p); };
    return { p, deleter };
}

static void ShowIDispatch(IDispatch* obj) {
    HRESULT hr;
    CComPtr<ITypeInfo> ti;
    hr = obj->GetTypeInfo(0, 0, &ti);
    ATLENSURE_SUCCEEDED(hr);
    ATLENSURE(ti);

    auto ta = GetTypeAttr(ti);

    for (WORD i = 0; i < ta->cFuncs; i++) {
        auto funcdesc = GetFuncDesc(ti, i);

        CComBSTR name, docstring;
        hr = ti->GetDocumentation(funcdesc->memid, &name, &docstring, nullptr, nullptr);
        ATLENSURE_SUCCEEDED(hr);

        std::wcout << L"function " << funcdesc->memid << L"\t" << std::wstring(name) << L"\t" << std::wstring(docstring) << L"\n";
    }
}

static std::unique_ptr<ITEMIDLIST, std::function<void(LPITEMIDLIST)>> MakePidl(LPITEMIDLIST pidl) {
    auto deleter = [](LPITEMIDLIST p) { CoTaskMemFree(p); };
    return { pidl, deleter };
}

/*
#define tv(mem) wprintf(L#mem L" %d\n", offsetof(TVITEMEXW, mem))

int foo() {
    tv(mask);
    tv(hItem);
    tv(state);
    tv(stateMask);
    tv(pszText);
    tv(cchTextMax);
    tv(iImage);
    tv(iSelectedImage);
    tv(cChildren);
    tv(lParam);
    tv(iIntegral);
    tv(uStateEx);
    tv(hwnd);
    tv(iExpandedImage);
    tv(iReserved);
    return 0;
}
*/

int wmain()
{
    //foo();
    HRESULT hr;

    hr = CoInitialize(nullptr);
    ATLENSURE_SUCCEEDED(hr);

    CComPtr<IShellDispatch6> shl;
    hr = shl.CoCreateInstance(__uuidof(Shell));
    ATLENSURE_SUCCEEDED(hr);

    CComPtr<IDispatch> _ws;
    hr = shl->Windows(&_ws);
    ATLENSURE_SUCCEEDED(hr);

    CComQIPtr<IShellWindows> ws(_ws);
    if (!ws) {
        std::wcerr << L"IShellWindows E_NOINTERFACE\n";
        return 0;
    }
    ShowIDispatch(ws);
    std::wcout << L"\n";

    CComPtr<IUnknown> _wse;
    hr = ws->_NewEnum(&_wse);
    ATLENSURE_SUCCEEDED(hr);
    CComQIPtr<IEnumVARIANT> wse(_wse);
    ATLENSURE(wse);

    while (1) {
        CComVariant wv;
        hr = wse->Next(1, &wv, nullptr);
        ATLENSURE_SUCCEEDED(hr);
        if (hr == S_FALSE)
            break;
        ATLENSURE(wv.vt == VT_DISPATCH);
        CComPtr<IDispatch> _w(wv.pdispVal);

        CComQIPtr<IWebBrowser2> w(_w);
        ATLENSURE(w);

        CComBSTR locUrl;
        hr = w->get_LocationURL(&locUrl);
        ATLENSURE_SUCCEEDED(hr);
        std::wcout << L"location: " << std::wstring(locUrl) << L"\n";

        CComQIPtr<IServiceProvider> ssp(w);
        if (!ssp)
            continue;
        CComPtr<IShellBrowser> sb;
        hr = ssp->QueryService(_uuidof(IShellBrowser), &sb);
        if (FAILED(hr) || !sb) {
            std::wcout << L"no sb found\n";
            continue;
        }
        std::array<UINT, 5> fcws = { FCW_STATUS, FCW_TOOLBAR, FCW_TREE, FCW_INTERNETBAR, FCW_PROGRESS };
        for (auto fcw : fcws) {
            HWND chwnd;
            if (FAILED(sb->GetControlWindow(fcw, &chwnd)) || !chwnd)
                continue;
            std::wcout << L"fcw " << fcw << L" hwnd " << chwnd << L"\n";
            if (fcw != FCW_TREE)
                continue;
            auto hnp = FindWindowExW(chwnd, nullptr, L"SysTreeView32", nullptr);
            if (!hnp)
                continue;
            std::wcout << L"found tree " << hnp << "\n";
            HTREEITEM root = TreeView_GetRoot(hnp);
            for (HTREEITEM itm = TreeView_GetChild(hnp, root); itm; itm = TreeView_GetNextSibling(hnp, itm)) {
                /*
                break;
                std::vector<wchar_t> text(MAX_PATH);
                TVITEMW itmdata{};
                itmdata.hItem = itm;
                itmdata.mask = TVIF_TEXT | TVIF_PARAM;
                itmdata.pszText = text.data();
                itmdata.cchTextMax = text.size() - 1;
                TreeView_GetItem(hnp, &itmdata);
                TreeView_GetItemPartRect
                */
            }
        }

        CComPtr<IShellView> sv;
        hr = sb->QueryActiveShellView(&sv);
        if (SUCCEEDED(hr) && sv) {
        }

        if (!locUrl.Length()) {
            /*
            CComBSTR target(L"file://E:/");
            CComVariant flag = navOpenInNewTab;
            CComVariant tfn = L"_self";
            hr = w->Navigate(target, &flag, &tfn, nullptr, nullptr);
            ATLENSURE_SUCCEEDED(hr);
            */
            PIDLIST_ABSOLUTE _pidl;
            hr = SHGetKnownFolderIDList(FOLDERID_Documents, KF_FLAG_DEFAULT, GetCurrentProcessToken(), &_pidl);
            ATLENSURE_SUCCEEDED(hr);
            auto pidl = MakePidl(_pidl);
            hr = sb->BrowseObject(pidl.get(), SBSP_SAMEBROWSER | SBSP_ABSOLUTE);
            ATLENSURE_SUCCEEDED(hr);
        }
        std::wcout << L"\n";
    }

    return 0;
}

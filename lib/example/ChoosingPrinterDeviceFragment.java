package com.tohome.fplus.fragments;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.app.Fragment;
import android.app.FragmentManager;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.sqlite.SQLiteDatabase;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;

import com.tohome.fplus.R;
import com.tohome.fplus.pojo.CollectChangeValues;
import com.tohome.fplus.pojo.CollectGetValues;
import com.tohome.fplus.pojo.GiveSave;
import com.tohome.fplus.pojo.GiveSaveDetail;
import com.tohome.fplus.pojo.GiveSaveHeader;
import com.tohome.fplus.pojo.OrderedProductPack;
import com.tohome.fplus.pojo.Store;
import com.tohome.fplus.sqlite.SQLiteDatabaseHandler;
import com.tohome.fplus.util.SessionManager;
import com.tohome.fplus.util.StringHelper;
import com.tohome.fplus.util.ThaiBaht;
import com.tohome.fplus.util.printinghelpers.Align;
import com.tohome.fplus.util.printinghelpers.HeaderPrinter;
import com.tohome.fplus.util.printinghelpers.WoosimFormatter;
import com.woosim.bt.WoosimPrinter;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Set;

/**
 * Created by pakorn on 13/10/2557.
 */
public class ChoosingPrinterDeviceFragment extends Fragment {
    List<Character> vowelAndToneMark;

    private SQLiteDatabaseHandler sqLite;
    private SQLiteDatabase db= null;
    private Context applicationContext;

    public static String EXTRA_DEVICE_ADDRESS = "device_address";
    private BluetoothAdapter mBtAdapter;
    private ArrayAdapter<String> mPairedDevicesArrayAdapter;
    private ArrayAdapter<String> mNewDevicesArrayAdapter;
    private String address;

    private WoosimPrinter woosim;
    private WoosimFormatter woosim4InchFormatter;
    private HeaderPrinter headerPrinter;
    private SessionManager sessionManager;
    private ArrayList<OrderedProductPack> orderedProductList;
    private String storeName = "";
    private String storeID = "";
    private String storeTax = "";
    private String invoiceNumber = "";
    private String storeAddress = "";
    private String selectedVatType = "";
    private String vat = "";
    private String discount = "";
    private String netPrice = "";
    private String PercentDiscount = "";
    private String Discount1 = "";
    private String Discount2 = "";
    private String totalPrice = "";
    private String thaiBathText = "";
    private String fromPage = "";

    private String saleCode = "";
    private String saleUserFullName;
    private String saleArea;
    private String saleAreaText;

    private String selectedCustomerType;
    private String billType = "";
    private String historyDate;

    private final static String EUC_KR = "EUC-KR";
    private final static String TIS_620 = "TIS-620";

/*	private final static String ISO_8859_1 = "ISO-8859-1";
    private final static String US_ASCII = "US-ASCII";
	private final static String UTF_16 = "UTF-16";
	private final static String UTF_16BE = "UTF-16BE";
	private final static String UTF_16LE = "UTF-16LE";
	private final static String UTF_8 = "UTF-8";*/

    //card data buffer
    private byte[] cardData;
    private byte[] extractdata = new byte[300];

    private DecimalFormat df = new DecimalFormat("0.00");

    //Change
    private String cn_no, ex_no, ex_date, ex_date_conv, store_id, store_name, store_address, difference, getProductTotalPrice, changeProductTotalPrice;

    private List<String> getProductID = new ArrayList<String>();
    private List<String> getProductName = new ArrayList<String>();
    private List<String> getProductAmount = new ArrayList<String>();
    private List<String> getProductUnit = new ArrayList<String>();
    private List<String> getProductStatus = new ArrayList<String>();
    private List<String> getProductLOT = new ArrayList<String>();
    private List<String> getProductPrice = new ArrayList<String>();

    private List<String> changeProductID = new ArrayList<String>();
    private List<String> changeProductName = new ArrayList<String>();
    private List<String> changeProductAmount = new ArrayList<String>();
    private List<String> changeProductUnit = new ArrayList<String>();
    private List<String> changeProductPrice = new ArrayList<String>();

    //Give
    private String giveSelectType, selectTypeName;

    private List<String> giveIDList = new ArrayList<String>();
    private List<String> giveNameList = new ArrayList<String>();
    private List<String> giveAmountList = new ArrayList<String>();
    private List<String> giveUnitList = new ArrayList<String>();
    private List<String> givePriceList = new ArrayList<String>();

    private LinearLayout linear_redio;
    private List<String> allCharacter = new ArrayList<String>();
    //private DecimalFormat changeFormat = new DecimalFormat("###0.00");
    private DecimalFormat changeFormat = new DecimalFormat("#,##0.00");

    //Transfer
    private String tf_date, tf_no, tf_type, tf_status, tf_destination, tf_remark, tf_area, tf_sqlitedate, tf_date_conv;

    //Withdraws
    private String wd_date, wd_no, wd_delivery_date, wd_status, wd_destination, wd_remark, wd_area, wd_sqlitedate, wd_date_conv;

    //TF & WD ProductList
    private List<String> product_id = new ArrayList<String>();
    private List<String> product_name = new ArrayList<String>();
    private List<String> product_qty = new ArrayList<String>();
    private List<String> product_R_qty = new ArrayList<String>();
    private List<String> product_unitname = new ArrayList<String>();

    //Collect
    private String CollectID, CollectDate, TotalGetValues, TotalChangeValues;
    private ArrayList<CollectGetValues> orderGetList = new ArrayList<CollectGetValues>();
    private ArrayList<CollectChangeValues> orderChangeList = new ArrayList<CollectChangeValues>();

    //Give
    private String GiveHeaderName;
    private ArrayList<GiveSave> GiveSaveList = new ArrayList<GiveSave>();
    private ArrayList<GiveSaveHeader> GiveSaveHeaderList = new ArrayList<GiveSaveHeader>();
    private ArrayList<GiveSaveDetail> GiveSaveDetailList = new ArrayList<GiveSaveDetail>();

    @SuppressLint("WrongConstant")
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        final View rootView = inflater.inflate(R.layout.device_list, container, false);

        db = getActivity().openOrCreateDatabase(sqLite.DATABASE_NAME, SQLiteDatabase.CREATE_IF_NECESSARY, null);
        db.setVersion(1);
        db.setLocale(Locale.getDefault());

        //getActivity().getBaseContext().getResources().updateConfiguration(config, getActivity().getBaseContext().getResources().getDisplayMetrics());

        applicationContext = getActivity().getApplicationContext();
        sqLite = SQLiteDatabaseHandler.getInstance(applicationContext);

        Bundle args = getArguments();

        if (args != null) {
            if (args.containsKey("OrderedProductList")) {
                orderedProductList = (ArrayList<OrderedProductPack>) (args.getSerializable("OrderedProductList"));
            }
            if (args.containsKey("storeName")) {
                storeName = args.getString("storeName");
            }
            if (args.containsKey("storeID")) {
                storeID = args.getString("storeID");
            }
            if (args.containsKey("storeTax")) {
                storeTax = args.getString("storeTax");
            }
            if (args.containsKey("invoiceNumber")) {
                invoiceNumber = args.getString("invoiceNumber");
            }
            if (args.containsKey("TotalPrice")) {
                totalPrice = args.getString("TotalPrice");
            }
            if (args.containsKey("storeAddress")) {
                storeAddress = args.getString("storeAddress");
            }
            if (args.containsKey("selectedVatType")) {
                selectedVatType = args.getString("selectedVatType");
            }
            if (args.containsKey("Vat")) {
                vat = args.getString("Vat");
            }
            if (args.containsKey("Discount")) {
                discount = args.getString("Discount");
            }
            if (args.containsKey("NetPrice")) {
                netPrice = args.getString("NetPrice");
            }
            if (args.containsKey("PercentDiscount")) {
                PercentDiscount = args.getString("PercentDiscount");
            }
            if (args.containsKey("Discount1")) {
                Discount1 = args.getString("Discount1");
            }
            if (args.containsKey("Discount2")) {
                Discount2 = args.getString("Discount2");
            }
            if (args.containsKey("historyDate")) {
                historyDate = args.getString("historyDate");
            }

            if (args.containsKey("CustomerType")) {
                selectedCustomerType = args.getString("CustomerType"); //TODO 2 types: General, CoOrCredit -> use for future determine bill layout
                if (selectedCustomerType.equals("General")) {
                    billType = "V";
                } else if (selectedCustomerType.equals("CoOrCredit") || selectedCustomerType.equalsIgnoreCase("NewStore")) {
                    String customerType = storeID.substring(0, 1);
                    if (customerType.equalsIgnoreCase("V")) {
                        billType = "V";
                    } else if (customerType.equalsIgnoreCase("C")) {
                        billType = "C";
                    } else {
                        billType = "V";
                        //Log.e("ChoosingPrinterDeviceFragment", "customerType wrong format");
                    }
                }else if(selectedCustomerType.equals("Change")){ ////////
                    billType = "Ch";
                    Bundle arguments = this.getArguments();
                    cn_no = arguments.getString("cn_no");
                    ex_no = arguments.getString("ex_no");
                    ex_date = arguments.getString("ex_date");
                    store_name = arguments.getString("store_name");
                    store_id = arguments.getString("store_id");
                    store_address = arguments.getString("store_address");
                    difference = arguments.getString("difference");

                    getProductID = arguments.getStringArrayList("getProductID");
                    getProductName = arguments.getStringArrayList("getProductName");
                    getProductAmount = arguments.getStringArrayList("getProductAmount");
                    getProductUnit = arguments.getStringArrayList("getProductUnit");
                    getProductStatus = arguments.getStringArrayList("getProductStatus");
                    getProductLOT = arguments.getStringArrayList("getProductLOT");
                    getProductTotalPrice = arguments.getString("getProductTotalPrice");
                    getProductPrice = arguments.getStringArrayList("getProductPrice");

                    changeProductID = arguments.getStringArrayList("changeProductID");
                    changeProductName = arguments.getStringArrayList("changeProductName");
                    changeProductAmount = arguments.getStringArrayList("changeProductAmount");
                    changeProductUnit = arguments.getStringArrayList("changeProductUnit");
                    changeProductTotalPrice = arguments.getString("changeProductTotalPrice");
                    changeProductPrice = arguments.getStringArrayList("changeProductPrice");

                    // Convert ex_date to dd/MM/yyyy
                    String date[] = ex_date.split("/");
                    String year[] = date[2].split(" ");
                    ex_date_conv = String.format("%02d", Integer.parseInt(date[0]))+"/"+String.format("%02d", Integer.parseInt(date[1]))+"/"+year[0];

                }else if(selectedCustomerType.equals("Give")){ ////////
                    billType = "Give";
                    Bundle arguments = this.getArguments();
                    ex_no = arguments.getString("ex_no");
                    ex_date = arguments.getString("ex_date");
                    store_id = arguments.getString("store_id");
                    store_name = arguments.getString("store_name");
                    store_address = arguments.getString("store_address");
                    giveSelectType = arguments.getString("giveSelectType");
                    selectTypeName = arguments.getString("selectTypeName");
                    totalPrice = arguments.getString("GiveTotalPrice");

                    giveIDList = arguments.getStringArrayList("giveIDList");
                    giveNameList = arguments.getStringArrayList("giveNameList");
                    giveAmountList = arguments.getStringArrayList("giveAmountList");
                    giveUnitList = arguments.getStringArrayList("giveUnitList");
                    givePriceList = arguments.getStringArrayList("givePriceList");

                    // Convert ex_date to dd/MM/yyyy
                    String date[] = ex_date.split("/");
                    String year[] = date[2].split(" ");
                    ex_date_conv = String.format("%02d", Integer.parseInt(date[0]))+"/"+String.format("%02d", Integer.parseInt(date[1]))+"/"+year[0];
                }else if(selectedCustomerType.equals("Transfer")) { ////////
                    billType = "Transfer";
                    Bundle arguments = this.getArguments();

                    tf_date = arguments.getString("tf_date");
                    tf_no = arguments.getString("tf_no");
                    tf_type = arguments.getString("tf_type");
                    tf_status  = arguments.getString("tf_status");
                    tf_destination = arguments.getString("tf_destination");
                    tf_remark = arguments.getString("tf_remark");
                    tf_area = arguments.getString("tf_area");
                    tf_sqlitedate = arguments.getString("tf_sqlitedate");

                    product_id = arguments.getStringArrayList("product_id");
                    product_name = arguments.getStringArrayList("product_name");
                    product_qty = arguments.getStringArrayList("product_qty");
                    product_R_qty = arguments.getStringArrayList("product_R_qty");
                    product_unitname = arguments.getStringArrayList("product_unitname");

                    // Convert ex_date to dd/MM/yyyy
                    String date[] = tf_date.split("/");
                    String year[] = date[2].split(" ");
                    tf_date_conv = String.format("%02d", Integer.parseInt(date[1]))+"/"+String.format("%02d", Integer.parseInt(date[0]))+"/"+year[0];
                }else if(selectedCustomerType.equals("Withdraws")) { ////////
                    billType = "Withdraws";
                    Bundle arguments = this.getArguments();

                    wd_date = arguments.getString("wd_date");
                    wd_no = arguments.getString("wd_no");
                    wd_delivery_date = arguments.getString("wd_delivery_date");
                    wd_status  = arguments.getString("wd_status");
                    wd_destination = arguments.getString("wd_destination");
                    wd_remark = arguments.getString("wd_remark");
                    wd_area = arguments.getString("wd_area");
                    wd_sqlitedate = arguments.getString("wd_sqlitedate");

                    product_id = arguments.getStringArrayList("product_id");
                    product_name = arguments.getStringArrayList("product_name");
                    product_qty = arguments.getStringArrayList("product_qty");
                    product_R_qty = arguments.getStringArrayList("product_R_qty");
                    product_unitname = arguments.getStringArrayList("product_unitname");

                    // Convert ex_date to dd/MM/yyyy
                    String date[] = wd_date.split("/");
                    String year[] = date[2].split(" ");
                    wd_date_conv = String.format("%02d", Integer.parseInt(date[1]))+"/"+String.format("%02d", Integer.parseInt(date[0]))+"/"+year[0];
                }else if(selectedCustomerType.equals("Collect")){
                    billType = "Collect";
                    Bundle arguments = this.getArguments();

                    CollectID = arguments.getString("CollectID");
                    CollectDate = arguments.getString("CollectDate");

                    orderGetList = (ArrayList<CollectGetValues>) (arguments.getSerializable("orderGetList"));
                    orderChangeList = (ArrayList<CollectChangeValues>) (arguments.getSerializable("orderChangeList"));

                    TotalGetValues = arguments.getString("TotalGetValues");
                    TotalChangeValues = arguments.getString("TotalChangeValues");

                    storeID = arguments.getString("storeID");
                    storeName  = arguments.getString("storeName");
                    storeAddress = arguments.getString("storeAddress");
                }else if(selectedCustomerType.equals("Give2")){
                    billType = "Give2";
                    Bundle arguments = this.getArguments();

                    GiveHeaderName = arguments.getString("GiveHeaderName");
                    GiveSaveList = (ArrayList<GiveSave>) (arguments.getSerializable("GiveSaveList"));
                    GiveSaveHeaderList = (ArrayList<GiveSaveHeader>) (arguments.getSerializable("GiveSaveHeaderList"));
                    GiveSaveDetailList = (ArrayList<GiveSaveDetail>) (arguments.getSerializable("GiveSaveDetailList"));
                }
            }
            if (args.containsKey("fromPage")) {
                fromPage = args.getString("fromPage");
            }
        } else {
            Log.e("PrintingBill class", "Bundle args is null");
        }

        vowelAndToneMark = new ArrayList<Character>();
        vowelAndToneMark.add('่');
        vowelAndToneMark.add('้');
        vowelAndToneMark.add('๊');
        vowelAndToneMark.add('๋');
        vowelAndToneMark.add('ั');
        vowelAndToneMark.add('็');
        vowelAndToneMark.add('ิ');
        vowelAndToneMark.add('ี');
        vowelAndToneMark.add('ุ');
        vowelAndToneMark.add('ู');
        vowelAndToneMark.add('ึ');
        vowelAndToneMark.add('ื');
        vowelAndToneMark.add('์');

        String[] spaceChar = {
                "ก","ข","ฃ","ค","ฅ","ฆ","ง","จ","ฉ","ช",
                "ซ","ฌ","ญ","ฎ","ฏ","ฐ","ฑ","ฒ","ณ","ด",
                "ต","ถ","ท","ธ","น","บ","ป","ผ","ฝ","พ",
                "ฟ","ภ","ม","ย","ร","ล","ว","ศ","ษ","ส",
                "ห","ฬ","อ","ฮ",

                "ะ","า","เ","แ","ใ","ไ","โ","ๅ","ๆ","ฯ","ำ",

                "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",

                "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",

                "~","!","@","#","$","%","^","&","*","(",")","_","+","-","=","{","}","|",";",":","<",">","/","?",".","฿",",","'","\"",

                "0","1","2","3","4","5","6","7","8","9",

                "๐","๑","๒","๓","๔","๕","๖","๗","๘","๙",

                " "
        };
        allCharacter = Arrays.asList(spaceChar);

        sessionManager = SessionManager.getInstance(getActivity().getApplicationContext());

        Button scanButton = (Button) rootView.findViewById(R.id.button_scan);
        scanButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                doDiscovery(rootView);
                v.setVisibility(View.GONE);
            }
        });

        //TODO Open //
        mPairedDevicesArrayAdapter = new ArrayAdapter<String>(getActivity(), R.layout.device_name);
        mNewDevicesArrayAdapter = new ArrayAdapter<String>(getActivity(), R.layout.device_name);

        // Find and set up the ListView for paired devices
        ListView pairedListView = (ListView) rootView.findViewById(R.id.paired_devices);
        pairedListView.setAdapter(mPairedDevicesArrayAdapter);
        pairedListView.setOnItemClickListener(mDeviceClickListener);

        // Find and set up the ListView for newly discovered devices
        ListView newDevicesListView = (ListView) rootView.findViewById(R.id.new_devices);
        newDevicesListView.setAdapter(mNewDevicesArrayAdapter);
        newDevicesListView.setOnItemClickListener(mDeviceClickListener);

        // Register for broadcasts when a device is discovered
        IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
        getActivity().registerReceiver(mReceiver, filter);

        // Register for broadcasts when discovery has finished
        filter = new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
        getActivity().registerReceiver(mReceiver, filter);

        // Get the local Bluetooth adapter
        mBtAdapter = BluetoothAdapter.getDefaultAdapter();

        // Get a set of currently paired devices
        Set<BluetoothDevice> pairedDevices = mBtAdapter.getBondedDevices();

        // If there are paired devices, add each one to the ArrayAdapter
        if (pairedDevices.size() > 0) {
            rootView.findViewById(R.id.title_paired_devices).setVisibility(View.VISIBLE);
            for (BluetoothDevice device : pairedDevices) {
                mPairedDevicesArrayAdapter.add(device.getName() + "\n" + device.getAddress());
            }
        } else {
            String noDevices = getResources().getText(R.string.none_paired).toString();
            mPairedDevicesArrayAdapter.add(noDevices);
        }
        //dialogPrinting();
//        // Unregister broadcast listeners
//        getActivity().unregisterReceiver(mReceiver);

        return rootView;
    }

    public void onDestroy() {
        super.onDestroy();
        // Make sure we're not doing discovery anymore
        if (mBtAdapter != null) {
            mBtAdapter.cancelDiscovery();
        }
        // Unregister broadcast listeners
        getActivity().unregisterReceiver(mReceiver);
    }


    private AdapterView.OnItemClickListener mDeviceClickListener = new AdapterView.OnItemClickListener() {
        public void onItemClick(AdapterView<?> av, View v, int arg2, long arg3) {
            mBtAdapter.cancelDiscovery();
            // Get the device MAC address, which is the last 17 chars in the View
            String info = ((TextView) v).getText().toString();
            address = info.substring(info.length() - 17);

            woosim = new WoosimPrinter();
            woosim4InchFormatter = new WoosimFormatter(woosim, WoosimFormatter.fourInchLineLength);
            headerPrinter = new HeaderPrinter(woosim4InchFormatter);

            woosim.setHandle(acthandler);
            printBill();
        }
    };

    private void printBill() {
        int reVal = woosim.BTConnection(address, false);
        if (reVal == 1) {
            Toast t = Toast.makeText(getActivity(), "CONNECTED", Toast.LENGTH_SHORT);
            t.show();
            dialogPrinting();
            //Toast t = Toast.makeText(getActivity(), "พิมพ์ใบเสร็จเสร็จสมบูรณ์", Toast.LENGTH_SHORT);
            //t.show();
        } else if (reVal == -2) {
            Toast t = Toast.makeText(getActivity(), "NOT CONNECTED", Toast.LENGTH_SHORT);
            t.show();
            woosim.closeConnection();
        } else if (reVal == -5) {
            Toast t = Toast.makeText(getActivity(), "DEVICE IS NOT BONDED", Toast.LENGTH_SHORT);
            t.show();
            woosim.closeConnection();
        } else if (reVal == -6) {
            Toast t = Toast.makeText(getActivity(), "ALREADY CONNECTED", Toast.LENGTH_SHORT);
            t.show();
            woosim.closeConnection();
        } else if (reVal == -8) {
            Toast t = Toast.makeText(getActivity(), "Please enable your Bluetooth and re-run this program!", Toast.LENGTH_LONG);
            t.show();
            woosim.closeConnection();
        } else {
            Toast t = Toast.makeText(getActivity(), "ELSE", Toast.LENGTH_SHORT);
            t.show();
            woosim.closeConnection();
        }

    }

    private void dialogPrinting() {
        List<String> TypeLabel = new ArrayList<String>();
        if ("V".equalsIgnoreCase(billType)) {
            TypeLabel.add("บิลเงินสด/ใบกำกับภาษี");
            TypeLabel.add("สำเนาบิลเงินสด/ใบกำกับภาษี");
            TypeLabel.add("สำเนาบิลเงินสด/ใบกำกับภาษี");
        } else if ("C".equalsIgnoreCase(billType)) {
            TypeLabel.add("ต้นฉบับใบเสร็จรับเงิน");
            TypeLabel.add("ต้นฉบับใบกำกับภาษี/ใบส่งของ");
            TypeLabel.add("สำเนาใบกำกับภาษี/สำเนาใบส่งของ");
        }else if("Ch".equalsIgnoreCase(billType)){ ////////
            TypeLabel.add("ใบลดหนี้/ใบกำกับภาษี");
            TypeLabel.add("สำเนาใบลดหนี้/ใบกำกับภาษี");
            TypeLabel.add("Nope");
            //linear_redio.setVisibility(View.INVISIBLE);
        }else if("Give".equalsIgnoreCase(billType)){ ////////
            TypeLabel.add("ใบลดหนี้/ใบกำกับภาษี");
            TypeLabel.add("สำเนาใบลดหนี้/ใบกำกับภาษี");
            TypeLabel.add("Nope");
            //linear_redio.setVisibility(View.INVISIBLE);
        }else if("Transfer".equalsIgnoreCase(billType)){ ////////
            TypeLabel.add("ใบรับโอนสินค้า");
            TypeLabel.add("สำเนาใบรับโอนสินค้า");
            TypeLabel.add("Nope");
            //linear_redio.setVisibility(View.INVISIBLE);
        }else if("Withdraws".equalsIgnoreCase(billType)){ ////////
            TypeLabel.add("ใบขอเบิกสินค้า");
            TypeLabel.add("สำเนาใบขอเบิกสินค้า");
            TypeLabel.add("Nope");
            //linear_redio.setVisibility(View.INVISIBLE);
        }else if("Collect".equalsIgnoreCase(billType)){
            TypeLabel.add("เอกสารการรับแลกซอง");
            TypeLabel.add("สำเนาเอกสารการรับแลกซอง");
            TypeLabel.add("Nope");
        }else if("Give2".equalsIgnoreCase(billType)){
            TypeLabel.add("เอกสารการตั้งโชว์สินค้า");
            TypeLabel.add("สำเนาเอกสารการตั้งโชว์สินค้า");
            TypeLabel.add("Nope");
        }

        final Dialog customDialog = new Dialog(getActivity());
        customDialog.setContentView(R.layout.custom_dialog_printing);
        customDialog.setCancelable(false);
        customDialog.setTitle("เลือกประเภทใบกำกับภาษี");

        final RadioGroup radioBillingTypeGroup;
        final RadioButton printing_typeodbilling3;
        Button btnPrint;
        Button btnFinish;

        ///// Edit By Kriangkrai /////
        radioBillingTypeGroup = (RadioGroup) customDialog.findViewById(R.id.radioBillingType);
        printing_typeodbilling3 = (RadioButton) customDialog.findViewById(R.id.printing_typeodbilling3);

        if("Ch".equalsIgnoreCase(billType) || "Give".equalsIgnoreCase(billType) || "Give2".equalsIgnoreCase(billType) || "Transfer".equalsIgnoreCase(billType)|| "Withdraws".equalsIgnoreCase(billType) || "Collect".equalsIgnoreCase(billType)){
            printing_typeodbilling3.setVisibility(View.INVISIBLE);
        }else{
            printing_typeodbilling3.setVisibility(View.VISIBLE);
        }
        //////////////////////////////

        for (int i = 0; i < radioBillingTypeGroup.getChildCount(); i++) {
            ((RadioButton) radioBillingTypeGroup.getChildAt(i)).setText(" " + (i + 1) + ". " + TypeLabel.get(i));
        }

        btnPrint = (Button) customDialog.findViewById(R.id.btnprint);
        btnFinish = (Button) customDialog.findViewById(R.id.btnfinish);

        //qqq
        btnPrint.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // get selected radio button from radioGroup
                int selectedRadioBttn = radioBillingTypeGroup.indexOfChild(customDialog.findViewById(radioBillingTypeGroup.getCheckedRadioButtonId()));
                String originalTextOfSelectedRadio = ((RadioButton) radioBillingTypeGroup.getChildAt(selectedRadioBttn)).getText().toString();
                if ("Ch".equalsIgnoreCase(billType)) {
                    Print_4inch_Ch_12T(selectedRadioBttn + 1, billType, cn_no, ex_date_conv, store_id, store_name, store_address, difference, null,
                            getProductID, getProductName, getProductAmount, getProductUnit, getProductStatus, getProductLOT, getProductPrice, getProductTotalPrice, "get");
                    PrintCut();
                    Print_4inch_Ch_12T(selectedRadioBttn + 1, billType, ex_no, ex_date_conv, store_id, store_name, store_address, difference, null,
                            changeProductID, changeProductName, changeProductAmount, changeProductUnit, null, null, changeProductPrice, changeProductTotalPrice, "change");


                    /*Print_3inch_Ch(selectedRadioBttn + 1, billType, cn_no, ex_date_conv, store_id, store_name, store_address, difference, null,
                            getProductID, getProductName, getProductAmount, getProductUnit, getProductStatus, getProductLOT, getProductPrice, getProductTotalPrice, "get");
                    PrintCut();
                    Print_3inch_Ch(selectedRadioBttn + 1, billType, ex_no, ex_date_conv, store_id, store_name, store_address, difference, null,
                            changeProductID, changeProductName, changeProductAmount, changeProductUnit, null, null, changeProductPrice, changeProductTotalPrice, "change");
                    */
                } else if ("Give".equalsIgnoreCase(billType)) {
                    Print_4inch_Ch_12T(selectedRadioBttn + 1, billType, ex_no, ex_date_conv, store_id, store_name, store_address, "0.00", selectTypeName,
                    //Print_3inch_Ch(selectedRadioBttn + 1, billType, ex_no, ex_date_conv, store_id, store_name, store_address, "0.00", selectTypeName,
                            giveIDList, giveNameList, giveAmountList, giveUnitList, null, null, givePriceList, totalPrice, "give");
                } else if ("Transfer".equalsIgnoreCase(billType)) {
                    Print_4inch_Tf_12T(selectedRadioBttn + 1, billType, tf_no, tf_date, tf_destination, tf_type, product_id, product_name, product_R_qty, product_unitname);
                    //Print_3inch_Tf(selectedRadioBttn + 1, billType, tf_no, tf_date, tf_destination, tf_type, product_id, product_name, product_R_qty, product_unitname);
                } else if ("Withdraws".equalsIgnoreCase(billType)) {
                    Print_4inch_Tf_12T(selectedRadioBttn + 1, billType, wd_no, wd_date, wd_destination, "เบิกสินค้าระหว่างทริป", product_id, product_name, product_R_qty, product_unitname);
                    //Print_3inch_Tf(selectedRadioBttn + 1, billType, wd_no, wd_date, wd_destination, "เบิกสินค้าระหว่างทริป", product_id, product_name, product_R_qty, product_unitname);
                } else if ("Collect".equalsIgnoreCase(billType)) {
                    Print_4inch_Col_12T(selectedRadioBttn + 1, billType, CollectID, CollectDate, storeID, storeName, storeAddress, orderGetList, orderChangeList);
                    //Print_3inch_Col(selectedRadioBttn + 1, billType, CollectID, CollectDate, storeID, storeName, storeAddress, orderGetList, orderChangeList);
                } else if ("Give2".equalsIgnoreCase(billType)) {
                    Print_4inch_Give_12T(selectedRadioBttn + 1, billType, GiveSaveList, GiveSaveHeaderList, GiveSaveDetailList);
                    //Print_3inch_Give2(selectedRadioBttn + 1, billType, GiveSaveList, GiveSaveHeaderList, GiveSaveDetailList);
                } else {
                    Print_4inch_12T(selectedRadioBttn + 1, billType);
                    //Print_3inch(selectedRadioBttn + 1, billType);
                }
                if (!originalTextOfSelectedRadio.contains("(พิมพ์สำเร็จ)")) {
                    ((RadioButton) radioBillingTypeGroup.getChildAt(selectedRadioBttn)).setText(originalTextOfSelectedRadio + " (พิมพ์สำเร็จ)");
                }
            }

        });

        btnFinish.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                woosim.closeConnection();
                customDialog.dismiss();
                FragmentManager fragmentManager = getFragmentManager();

                if (fromPage.equals("SalePreviewOrderedProducts")) {
                    Fragment fragment = new SaleChoosingCustomerTypeFragment();
                    // clear all back stack
                    fragmentManager.popBackStack(null, FragmentManager.POP_BACK_STACK_INCLUSIVE);
                    fragmentManager.beginTransaction()
                            .replace(R.id.frame_container, fragment).commit();
                } else {
                    fragmentManager.popBackStack();
                }
            }

        });

        customDialog.show();
    }


    public Handler acthandler = new Handler() {

        public void handleMessage(Message msg) {
            if (msg.what == 0x01) {
                Log.e("+++Activity+++", "******0x01");
                Object obj1 = msg.obj;
                cardData = (byte[]) obj1;
                //ToastMessage();
            } else if (msg.what == 0x02) {
                //ardData[msg.arg1] = (byte) msg.arg2;
                Log.e("+++Activity+++", "MSRFAIL: [" + msg.arg1 + "]: ");
            } else if (msg.what == 0x03) {
                Log.e("+++Activity+++", "******EOT");
            } else if (msg.what == 0x04) {
                Log.e("+++Activity+++", "******ETX");
            } else if (msg.what == 0x05) {
                Log.e("+++Activity+++", "******NACK");
            }
        }

    };
    //www
    private void Print_4inch_12T_TEST(int billingTypeNumber, String billType) {


        byte[] init = {0x1b, '@'};
        byte[] align_right = {27, 97, 50};
        byte[] align_left = {27, 97, 48};
        byte[] lf = {0x0a}; //0x0a          textViewVat.setText(String.format("%.2f",getVatAmount(totalPrice)));

        woosim.controlCommand(init, init.length);


        woosim4InchFormatter.print("บริษัท วันทูเทรดดิ้ง จำกัด", Align.left,0, 0, false);
        woosim4InchFormatter.print("TT",Align.end,1, 0, false);

        woosim4InchFormatter.print("บริษัท วันทูเทรดดิ้ง จำกัด",Align.center,0, 0, true);
        woosim4InchFormatter.print("TT",Align.end,1, 0, false);

        woosim4InchFormatter.print("บริษัท วันทูเทรดดิ้ง จำกัด",Align.right,3, 0, false);


        try {
            woosim.printBitmap("/sdcard/images/woosim.bmp");
        } catch (IOException e) {
            e.printStackTrace();
        }
        woosim.controlCommand(lf, lf.length);
        woosim.controlCommand(lf, lf.length);


        byte[] ff = {0};
        woosim.controlCommand(ff, 1);

        woosim.printSpool(true);
        cardData = null;

    }

    private void Print_3inch_Give2(int billingTypeNumber, String billType,
                                   ArrayList<GiveSave> GiveSaveList,
                                   ArrayList<GiveSaveHeader> GiveSaveHeaderList,
                                   ArrayList<GiveSaveDetail> GiveSaveDetailList
    ){
        this.GiveSaveList = GiveSaveList;
        this.GiveSaveHeaderList = GiveSaveHeaderList;
        this.GiveSaveDetailList = GiveSaveDetailList;

        saleCode = sessionManager.getSaleCode();
        saleUserFullName = sessionManager.getUserFullName();

        byte[] init = {0x1b, '@'};
        byte[] align_right = {27, 97, 50};
        byte[] align_left = {27, 97, 48};
        byte[] lf = {0x0a};

        // 4/29/2016 11:41:00 AM

        String[] cutDate = GiveSaveList.get(0).getGIVE_DATE().split(" ");
        String[] cutDay = cutDate[0].split("-");
        String[] cutTime = cutDate[1].split(":");
        String time = cutTime[0]+":"+cutTime[1]+" น.";
        String date = String.format("%02d", Integer.parseInt(cutDay[2]))+"/"+String.format("%02d", Integer.parseInt(cutDay[1]))+"/"+cutDay[0]+" "+time;

        woosim.controlCommand(init, init.length);
        headerPrinter.printFPlusHeader(false);

        String header = "";
        String footer = "";
        String TypeHeader = "";
        String DetailHeader = "";

        for(int i=0; i<= GiveSaveHeaderList.size()-1; i++){
            if(GiveSaveHeaderList.get(0).getGIVE_HEAD_COL().equals("ร้านค้า")){
                TypeHeader = "Store";
                DetailHeader = GiveSaveHeaderList.get(0).getGIVE_HEAD_COL_DESC();
                break;
            }else if(GiveSaveHeaderList.get(0).getGIVE_HEAD_COL().equals("เครดิตเขต")){
                TypeHeader = "Credit";
                DetailHeader = GiveSaveHeaderList.get(0).getGIVE_HEAD_COL_DESC();
                break;
            }else{}
        }

        switch (billingTypeNumber) {
            case 1:
                if(TypeHeader.equals("Store")){
                    header = "                          (เอกสารการตั้งโชว์สินค้า)";
                }else if(TypeHeader.equals("Credit")){
                    header = "                         (เอกสารรายการเครดิตเบิก)";
                }else{
                    header = "                           (เอกสารการแจกสินค้า)";
                }
                break;

            case 2:
                if(TypeHeader.equals("Store")){
                    header = "                        (สำเนาเอกสารการตั้งโชว์สินค้า)";
                }else if(TypeHeader.equals("Credit")){
                    header = "                       (สำเนาเอกสารรายการเครดิตเบิก)";
                }else{
                    header = "                        (สำเนาเอกสารการแจกสินค้า)";
                }
                break;

            case 3:
                if(TypeHeader.equals("Store")){
                    header = "                        (สำเนาเอกสารการตั้งโชว์สินค้า)";
                }else if(TypeHeader.equals("Credit")){
                    header = "                       (สำเนาเอกสารรายการเครดิตเบิก)";
                }else{
                    header = "                        (สำเนาเอกสารการแจกสินค้า)";
                }
                break;

            default:
                header = "";
                break;
        }

        footer = "ลงชื่อพนักงานขาย " + saleCode + " " + saleUserFullName;

        woosim.saveSpool(TIS_620, header + "\r\n\r\n", 0, false);
        woosim.saveSpool(TIS_620, "เลขที่ ", 0, false);
        woosim.saveSpool(TIS_620, GiveSaveList.get(0).getGIVE_ID(), 0, true);
        //woosim.saveSpool(TIS_620, "                                        วันที่ ", 0, false);
        woosim.saveSpool(TIS_620, "                               วันที่ ", 0, false);
        woosim.saveSpool(TIS_620, date + "\r\n", 0, true);

        if(TypeHeader.equals("Store")){
            ArrayList<Store> StoreList = new ArrayList<Store>();
            StoreList.addAll(sqLite.getOneStore(DetailHeader));

            woosim.saveSpool(TIS_620, "ร้านค้า " + StoreList.get(0).getStoreName(), 0, false);
            woosim.controlCommand(align_right, align_right.length);
            woosim.saveSpool(TIS_620, "    " + StoreList.get(0).getStoreID() + "\r\n", 0, false);
            woosim.controlCommand(align_left, align_left.length);
            woosim.saveSpool(TIS_620, "ที่อยู่ " + StoreList.get(0).getStoreAddress() + "\r\n", 0, false);
        }else if(TypeHeader.equals("Credit")){
            woosim.saveSpool(TIS_620, "เครดิตเขต " + DetailHeader + "\r\n", 0, false);
        }else{
            for(int i=0; i<= GiveSaveHeaderList.size()-1; i++){
                woosim.saveSpool(TIS_620, GiveSaveHeaderList.get(i).getGIVE_HEAD_COL()+" " + GiveSaveHeaderList.get(i).getGIVE_HEAD_COL_DESC() + "\r\n", 0, false);
            }
        }

        woosim.saveSpool(TIS_620, "\r\n", 0, false);

        // Change
        woosim.saveSpool(TIS_620, "รายการ"+GiveHeaderName+"\r\n", 0, true);
        //qww
        woosim.saveSpool(TIS_620, "---------------------------------------------------------------------\r\n", 0, false);
        woosim.saveSpool(TIS_620, "    ชื่อสินค้า                               จำนวน               มูลค่า\r\n", 0, true);

        for(int i=0; i<=GiveSaveDetailList.size()-1; i++){

            String unitName = sqLite.getUnitNameByUnitCode(GiveSaveDetailList.get(i).getGIVE_UNITCODE());

            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(String.valueOf(i+1), 2, "L") + "  ", 0, false);
            String restProductName = generateProductName(sqLite.getProductName(GiveSaveDetailList.get(i).getGIVE_ITEMCODEID()), billType);

            String giveSaveDetail = StringHelper.generateStringWithSuitableSpace(GiveSaveDetailList.get(i).getGIVE_QTY(), 3, "R") + " " +
                    StringHelper.generateStringWithSuitableSpace(unitName, 5 + woosim4InchFormatter.getNoOfUpperLowerChar(unitName), "L") + " ";
            woosim.saveSpool(TIS_620, giveSaveDetail, 0, false);
            //here

            double valueList = Double.parseDouble(GiveSaveDetailList.get(i).getGIVE_PRICE());
            BigDecimal bb = new BigDecimal(valueList);
            BigDecimal divideB = bb.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);

            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(String.valueOf(changeFormat.format(divideB)), 15, "R") + "\r\n", 0, false);
            while (!restProductName.equals("")) {
                restProductName = generateRestProductName(restProductName, billType);
            }
        }

        /*woosim.controlCommand(lf, lf.length);
        woosim.saveSpool(TIS_620, "\r\n", 0, false);

        woosim.saveSpool(TIS_620, "มูลค่าซองที่รับกลับ", 0, false);
        woosim.controlCommand(align_right, align_right.length);
        woosim.saveSpool(TIS_620, TotalGetValues + "\r\n", 0, false);
        woosim.controlCommand(align_left, align_right.length);

        woosim.saveSpool(TIS_620, "มูลค่าซองที่ใช้ไป", 0, false);
        woosim.controlCommand(align_right, align_right.length);
        woosim.saveSpool(TIS_620, TotalChangeValues + "\r\n", 0, false);
        woosim.controlCommand(align_left, align_right.length);*/

        woosim.saveSpool(TIS_620, "\r\n\r\n", 0, false);

        //Edit By Kriangkrai
        woosim.saveSpool(TIS_620, "\r\n", 0, false);
        woosim.saveSpool(TIS_620, footer, 0, true);
        woosim.controlCommand(align_right, align_right.length);

        if(TypeHeader.equals("Credit")){
            woosim.saveSpool(TIS_620, "..................... \r\nลายเซ็นเครดิต    ", 0, true);
        }else{

            woosim.saveSpool(TIS_620, "..................... \r\nลายเซ็นลูกค้า   ", 0, true);
        }
        //woosim.saveSpool(TIS_620, "..................... \r\nsaleUserFullName    \r\nลายเซ็นผู้รับโอน  ", 0, true);*/

        woosim.saveSpool(TIS_620, "\r\n\r\n\n", 0, true);
        woosim.controlCommand(align_left, align_left.length);
        woosim.saveSpool(TIS_620, "..................... \r\n  ลายเซ็น Supervisor", 0, true);

        woosim.saveSpool(TIS_620, "\r\n\r\n\r\n\r\n", 0, true);

        try {
            woosim.printBitmap("/sdcard/images/woosim.bmp");
        } catch (IOException e) {
            e.printStackTrace();
        }
        woosim.controlCommand(lf, lf.length);
        woosim.controlCommand(lf, lf.length);

        byte[] ff = {0};
        woosim.controlCommand(ff, 1);

        woosim.printSpool(true);
        cardData = null;
        //qwer
    }

    private void Print_4inch_Give_12T(int billingTypeNumber, String billType,
                                   ArrayList<GiveSave> GiveSaveList,
                                   ArrayList<GiveSaveHeader> GiveSaveHeaderList,
                                   ArrayList<GiveSaveDetail> GiveSaveDetailList
    ){
        this.GiveSaveList = GiveSaveList;
        this.GiveSaveHeaderList = GiveSaveHeaderList;
        this.GiveSaveDetailList = GiveSaveDetailList;

        saleCode = sessionManager.getSaleCode();
        saleUserFullName = sessionManager.getUserFullName();

        byte[] init = {0x1b, '@'};
        byte[] lf = {0x0a};

        // 4/29/2016 11:41:00 AM

        String[] cutDate = GiveSaveList.get(0).getGIVE_DATE().split(" ");
        String[] cutDay = cutDate[0].split("-");
        String[] cutTime = cutDate[1].split(":");
        String time = cutTime[0]+":"+cutTime[1]+" น.";
        String date = String.format("%02d", Integer.parseInt(cutDay[2]))+"/"+String.format("%02d", Integer.parseInt(cutDay[1]))+"/"+cutDay[0]+" "+time;

        woosim.controlCommand(init, init.length);
        headerPrinter.print12TradingHeader(false);

        String header;
        String footer;
        String TypeHeader = "";
        String DetailHeader = "";

        for(int i=0; i<= GiveSaveHeaderList.size()-1; i++){
            if(GiveSaveHeaderList.get(0).getGIVE_HEAD_COL().equals("ร้านค้า")){
                TypeHeader = "Store";
                DetailHeader = GiveSaveHeaderList.get(0).getGIVE_HEAD_COL_DESC();
                break;
            }else if(GiveSaveHeaderList.get(0).getGIVE_HEAD_COL().equals("เครดิตเขต")){
                TypeHeader = "Credit";
                DetailHeader = GiveSaveHeaderList.get(0).getGIVE_HEAD_COL_DESC();
                break;
            }else{}
        }

        switch (billingTypeNumber) {
            case 1:
                if(TypeHeader.equals("Store")){
                    header = "(เอกสารการตั้งโชว์สินค้า)";
                }else if(TypeHeader.equals("Credit")){
                    header = "(เอกสารรายการเครดิตเบิก)";
                }else{
                    header = "(เอกสารการแจกสินค้า)";
                }
                break;

            case 2:
            case 3:
                if(TypeHeader.equals("Store")){
                    header = "(สำเนาเอกสารการตั้งโชว์สินค้า)";
                }else if(TypeHeader.equals("Credit")){
                    header = "(สำเนาเอกสารรายการเครดิตเบิก)";
                }else{
                    header = "(สำเนาเอกสารการแจกสินค้า)";
                }
                break;

            default:
                header = "";
                break;
        }

        footer = "ลงชื่อพนักงานขาย " + saleCode + " " + saleUserFullName;

        woosim4InchFormatter.print(header,Align.center,2, 0, true);
        woosim4InchFormatter.print("เลขที่ "+GiveSaveList.get(0).getGIVE_ID()+"                               วันที่ "+date,Align.left,1, 0, false);

        if(TypeHeader.equals("Store")){
            ArrayList<Store> StoreList = new ArrayList<Store>();
            StoreList.addAll(sqLite.getOneStore(DetailHeader));

            woosim4InchFormatter.print("ร้านค้า " + StoreList.get(0).getStoreName(),Align.left,0, 0, false);
            woosim4InchFormatter.print(StoreList.get(0).getStoreID(),Align.right,1, 0, false);
            woosim4InchFormatter.print("ที่อยู่ " + StoreList.get(0).getStoreAddress(),Align.left,1, 0, false);
        }else if(TypeHeader.equals("Credit")){
            woosim4InchFormatter.print("เครดิตเขต " + DetailHeader,Align.left,1, 0, false);
        }else{
            for(int i=0; i<= GiveSaveHeaderList.size()-1; i++){
                woosim4InchFormatter.print(GiveSaveHeaderList.get(i).getGIVE_HEAD_COL()+" " + GiveSaveHeaderList.get(i).getGIVE_HEAD_COL_DESC(),Align.left,1, 0, false);
            }
        }

        woosim4InchFormatter.print("", Align.left,1, 0, false);

        woosim4InchFormatter.print("รายการ"+GiveHeaderName, Align.left,1, 0, true);
        woosim4InchFormatter.print("---------------------------------------------------------------------",Align.left,1, 0, false);
        woosim4InchFormatter.print("    รายการสินค้า                           จำนวน               มูลค่า",Align.left,1, 0, true);

        for(int i=0; i<=GiveSaveDetailList.size()-1; i++){

            String unitName = sqLite.getUnitNameByUnitCode(GiveSaveDetailList.get(i).getGIVE_UNITCODE());

            woosim4InchFormatter.print(StringHelper.generateStringWithSuitableSpace(String.valueOf(i+1), 2, "L") + "  ",Align.left,0, 0, false);
            String restProductName = generateProductName(sqLite.getProductName(GiveSaveDetailList.get(i).getGIVE_ITEMCODEID()), billType);

            double valueList = Double.parseDouble(GiveSaveDetailList.get(i).getGIVE_PRICE());
            BigDecimal bb = new BigDecimal(valueList);
            BigDecimal divideB = bb.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);

            String giveSaveDetail = StringHelper.generateStringWithSuitableSpace(GiveSaveDetailList.get(i).getGIVE_QTY(), 3, "R") + " " +
                    StringHelper.generateStringWithSuitableSpace(unitName, 5 + woosim4InchFormatter.getNoOfUpperLowerChar(unitName), "L") + " " +
                    StringHelper.generateStringWithSuitableSpace(String.valueOf(changeFormat.format(divideB)), 15, "R");
            woosim4InchFormatter.print(giveSaveDetail, Align.left,1, 0, false);

            while (!restProductName.equals("")) {
                restProductName = generateRestProductName(restProductName, billType);
            }
        }

        woosim4InchFormatter.print("",Align.left,3, 0, false);
        woosim4InchFormatter.print(footer,Align.left,1, 0, true);

        if(TypeHeader.equals("Credit")){
            woosim4InchFormatter.print("..................... \r\nลายเซ็นเครดิต    ",Align.right,3, 0, true);
        }else{
            woosim4InchFormatter.print("..................... \r\nลายเซ็นลูกค้า   ",Align.right,3, 0, true);
        }

        woosim4InchFormatter.print("..................... \r\n  ลายเซ็น Supervisor",Align.left,4, 0, true);

        try {
            woosim.printBitmap("/sdcard/images/woosim.bmp");
        } catch (IOException e) {
            e.printStackTrace();
        }
        woosim.controlCommand(lf, lf.length);

        byte[] ff = {0};
        woosim.controlCommand(ff, 1);

        woosim.printSpool(true);
        cardData = null;
        //qwer
    }

    private void Print_3inch_Col(int billingTypeNumber, String billType,
                                 String collect_id, String collect_date,
                                 String store_id, String store_name, String store_address,
                                 ArrayList<CollectGetValues> get_order, ArrayList<CollectChangeValues> change_order){

        saleCode = sessionManager.getSaleCode();
        saleUserFullName = sessionManager.getUserFullName();

        byte[] init = {0x1b, '@'};
        byte[] align_right = {27, 97, 50};
        byte[] align_left = {27, 97, 48};
        byte[] lf = {0x0a};

        // 4/29/2016 11:41:00 AM

        String[] cutDate = collect_date.split(" ");
        String[] cutDay = cutDate[0].split("/");
        String date = String.format("%02d", Integer.parseInt(cutDay[1]))+"/"+String.format("%02d", Integer.parseInt(cutDay[0]))+"/"+cutDay[2];

        Log.e("LogPrint", "billingTypeNumber :"+String.valueOf(billingTypeNumber));
        Log.e("LogPrint", "billType :"+billType);
        Log.e("LogPrint", "collect_id :"+collect_id);
        Log.e("LogPrint", "collect_date :"+date);
        Log.e("LogPrint", "store_id :"+store_id);
        Log.e("LogPrint", "store_name :"+store_name);
        Log.e("LogPrint", "store_address :" + store_address);
        Log.e("LogPrint", "------------------------------");

        for(int i=0; i<=get_order.size()-1; i++){
            Log.e("LogPrint", String.valueOf(i + 1)+" "+get_order.get(i).getCol_GetName()+" "+get_order.get(i).getGetQty()+" ซอง");
        }

        Log.e("LogPrint", "------------------------------");

        for(int i=0; i<=change_order.size()-1; i++){
            Log.e("LogPrint", String.valueOf(i+1)+" "+change_order.get(i).getCol_ChangeName()+" "+change_order.get(i).getGetChangeQty()+" "+change_order.get(i).getCol_ChangeUnit());
        }

        woosim.controlCommand(init, init.length);

        headerPrinter.printFPlusHeader(false);

        String header = "";
        String footer = "";

        switch (billingTypeNumber) {
            case 1:
                header = "                          (เอกสารการรับแลกซอง)";
                break;

            case 2:
                header = "                        (สำเนาเอกสารการรับแลกซอง)";
                break;

            case 3:
                header = "                        (สำเนาเอกสารการรับแลกซอง)";
                break;

            default:
                header = "";
                break;
        }

        footer = "ลงชื่อผู้รับแลก " + saleCode + " " + saleUserFullName;

        woosim.saveSpool(TIS_620, header + "\r\n\r\n", 0, false);
        woosim.saveSpool(TIS_620, "เลขที่ ", 0, false);
        woosim.saveSpool(TIS_620, collect_id, 0, true);
        woosim.saveSpool(TIS_620, "                                        วันที่ ", 0, false);
        woosim.saveSpool(TIS_620, date + "\r\n", 0, true);

        woosim.saveSpool(TIS_620, "ชื่อลูกค้า " + store_name, 0, false);
        woosim.controlCommand(align_right, align_right.length);
        woosim.saveSpool(TIS_620, "รหัส " + store_id + "\r\n", 0, false);
        woosim.controlCommand(align_left, align_left.length);
        woosim.saveSpool(TIS_620, "ที่อยู่ " + store_address + "\r\n\r\n", 0, false);

        // Change
        woosim.saveSpool(TIS_620, "รายการสินค้าที่ให้กับลูกค้า\r\n", 0, true);
        //qww
        woosim.saveSpool(TIS_620, "---------------------------------------------------------------------\r\n", 0, false);
        woosim.saveSpool(TIS_620, "    ชื่อสินค้า                                จำนวน              มูลค่า\r\n", 0, true);

        for(int i=0; i<=change_order.size()-1; i++){

            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(String.valueOf(i+1), 2, "L") + "  ", 0, false);
            String restProductName = generateProductName(change_order.get(i).getCol_ChangeName(), billType);
            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(change_order.get(i).getGetChangeQty(), 3, "R") + " ", 0, false);
            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(change_order.get(i).getCol_ChangeUnit(), 5 + woosim4InchFormatter.getNoOfUpperLowerChar(change_order.get(i).getCol_ChangeUnit()), "L") + " ", 0, false);
            //here

            double valueList = Double.parseDouble(change_order.get(i).getCol_ChangeValue()) * Double.parseDouble(change_order.get(i).getGetChangeQty());
            BigDecimal bb = new BigDecimal(valueList);
            BigDecimal divideB = bb.divide(new BigDecimal(1),4,4);

            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(String.valueOf(changeFormat.format(divideB)), 15, "R") + "\r\n", 0, false);
            while (!restProductName.equals("")) {
                restProductName = generateRestProductName(restProductName, billType);
            }
        }

        woosim.controlCommand(lf, lf.length);
        woosim.saveSpool(TIS_620, "\r\n", 0, false);

        // Get
        woosim.saveSpool(TIS_620, "รายการซองที่รับจากลูกค้า\r\n", 0, true);
        woosim.saveSpool(TIS_620, "---------------------------------------------------------------------\r\n", 0, false);
        woosim.saveSpool(TIS_620, "    ชื่อสินค้า                                จำนวน              มูลค่า\r\n", 0, true);

        for(int i=0; i<=get_order.size()-1; i++){

            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(String.valueOf(i+1), 2, "L") + "  ", 0, false);
            String restProductName = generateProductName(get_order.get(i).getCol_GetName(), billType);
            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(get_order.get(i).getGetQty(), 3, "R") + " ", 0, false);
            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace("ซอง", 5 + woosim4InchFormatter.getNoOfUpperLowerChar("ซอง"), "L") + " ", 0, false);

            double valueList = Double.parseDouble(get_order.get(i).getCol_GetValue()) * Double.parseDouble(get_order.get(i).getGetQty());
            BigDecimal bb = new BigDecimal(valueList);
            BigDecimal divideB = bb.divide(new BigDecimal(1), 4, 4);

            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(String.valueOf(changeFormat.format(divideB)), 15, "R") + "\r\n", 0, false);

            while (!restProductName.equals("")) {
                restProductName = generateRestProductName(restProductName, billType);
            }
        }

        woosim.controlCommand(lf, lf.length);
        woosim.saveSpool(TIS_620, "\r\n", 0, false);

        woosim.saveSpool(TIS_620, "มูลค่าซองที่รับกลับ", 0, false);
        woosim.controlCommand(align_right, align_right.length);
        woosim.saveSpool(TIS_620, TotalGetValues + "\r\n", 0, false);
        woosim.controlCommand(align_left, align_right.length);

        woosim.saveSpool(TIS_620, "มูลค่าซองที่ใช้ไป", 0, false);
        woosim.controlCommand(align_right, align_right.length);
        woosim.saveSpool(TIS_620, TotalChangeValues + "\r\n", 0, false);
        woosim.controlCommand(align_left, align_right.length);

        //Edit By Kriangkrai
        woosim4InchFormatter.print("", Align.left, 3, 0, false);
        //woosim.saveSpool(TIS_620, "..................... \r\nsaleUserFullName    \r\nลายเซ็นผู้รับโอน  ", 0, true);*/
        headerPrinter.printFooter(footer);

        try {
            woosim.printBitmap("/sdcard/images/woosim.bmp");
        } catch (IOException e) {
            e.printStackTrace();
        }
        woosim.controlCommand(lf, lf.length);
        woosim.controlCommand(lf, lf.length);

        byte[] ff = {0};
        woosim.controlCommand(ff, 1);

        woosim.printSpool(true);
        cardData = null;
        //qwer
    }


    private void Print_4inch_Col_12T(int billingTypeNumber, String billType,
                                 String collect_id, String collect_date,
                                 String store_id, String store_name, String store_address,
                                 ArrayList<CollectGetValues> get_order, ArrayList<CollectChangeValues> change_order){

        saleCode = sessionManager.getSaleCode();
        saleUserFullName = sessionManager.getUserFullName();

        byte[] init = {0x1b, '@'};
        byte[] align_right = {27, 97, 50};
        byte[] align_left = {27, 97, 48};
        byte[] lf = {0x0a};

        // 4/29/2016 11:41:00 AM

        String[] cutDate = collect_date.split(" ");
        String[] cutDay = cutDate[0].split("/");
        String date = String.format("%02d", Integer.parseInt(cutDay[1]))+"/"+String.format("%02d", Integer.parseInt(cutDay[0]))+"/"+cutDay[2];


        woosim.controlCommand(init, init.length);
        headerPrinter.print12TradingHeader(false);

        String header = "";
        String footer = "";

        switch (billingTypeNumber) {
            case 1:
                header = "(เอกสารการรับแลกซอง)";
                break;

            case 2:
            case 3:
                header = "(สำเนาเอกสารการรับแลกซอง)";
                break;

            default:
                header = "";
                break;
        }

        footer = "ลงชื่อผู้รับแลก " + saleCode + " " + saleUserFullName;

        woosim4InchFormatter.print(header,Align.center,2, 0, true);
        headerPrinter.printStoreDetail(store_id, collect_id, store_name, date, store_address, false, "");


        woosim4InchFormatter.print("รายการสินค้าที่ให้กับลูกค้า",Align.left,1, 0, true);
        woosim4InchFormatter.print("---------------------------------------------------------------------",Align.left,1, 0, false);
        woosim4InchFormatter.print("    รายการสินค้า                            จำนวน              มูลค่า",Align.left,1, 0, true);


        for(int i=0; i<=change_order.size()-1; i++){

            woosim4InchFormatter.print(StringHelper.generateStringWithSuitableSpace(String.valueOf(i+1), 2, "L") + "  ",Align.left,0, 0, false);
            String restProductName = generateProductName(change_order.get(i).getCol_ChangeName(), billType);
            String changeOrderDetail = " " + StringHelper.generateStringWithSuitableSpace(change_order.get(i).getGetChangeQty(), 3, "R") +
                    StringHelper.generateStringWithSuitableSpace(change_order.get(i).getCol_ChangeUnit(), 5 + woosim4InchFormatter.getNoOfUpperLowerChar(change_order.get(i).getCol_ChangeUnit()), "L") + " ";
            woosim4InchFormatter.print(changeOrderDetail, Align.left,0, 0, false);


            double valueList = Double.parseDouble(change_order.get(i).getCol_ChangeValue()) * Double.parseDouble(change_order.get(i).getGetChangeQty());
            BigDecimal bb = new BigDecimal(valueList);
            BigDecimal divideB = bb.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);

            woosim4InchFormatter.print(StringHelper.generateStringWithSuitableSpace(String.valueOf(changeFormat.format(divideB)), 15, "R"),Align.left,1, 0, false);
            while (!restProductName.equals("")) {
                restProductName = generateRestProductName(restProductName, billType);
            }
        }

        //woosim.controlCommand(lf, lf.length);
        woosim4InchFormatter.print("",Align.left,1, 0, false);

        woosim4InchFormatter.print("รายการซองที่รับจากลูกค้า",Align.left,1, 0, true);
        woosim4InchFormatter.print("---------------------------------------------------------------------",Align.left,1, 0, false);
        woosim4InchFormatter.print("    รายการสินค้า                            จำนวน              มูลค่า",Align.left,1, 0, true);

        for(int i=0; i<=get_order.size()-1; i++){

            woosim4InchFormatter.print(StringHelper.generateStringWithSuitableSpace(String.valueOf(i+1), 2, "L") + "  ",Align.left,0, 0, false);
            String restProductName = generateProductName(get_order.get(i).getCol_GetName(), billType);
            woosim4InchFormatter.print(StringHelper.generateStringWithSuitableSpace(get_order.get(i).getGetQty(), 3, "R") + " ",Align.left,0, 0, false);
            woosim4InchFormatter.print(StringHelper.generateStringWithSuitableSpace("ซอง", 5 + woosim4InchFormatter.getNoOfUpperLowerChar("ซอง"), "L") + " ",Align.left,0, 0, false);

            double valueList = Double.parseDouble(get_order.get(i).getCol_GetValue()) * Double.parseDouble(get_order.get(i).getGetQty());
            BigDecimal bb = new BigDecimal(valueList);
            BigDecimal divideB = bb.divide(new BigDecimal(1), 4, RoundingMode.HALF_UP);

            woosim4InchFormatter.print(StringHelper.generateStringWithSuitableSpace(String.valueOf(changeFormat.format(divideB)), 15, "R"),Align.left,1, 0, false);

            while (!restProductName.equals("")) {
                restProductName = generateRestProductName(restProductName, billType);
            }
        }

        woosim.controlCommand(lf, lf.length);
        woosim4InchFormatter.print("",Align.left,1, 0, false);

        woosim4InchFormatter.print("มูลค่าซองที่รับกลับ",Align.left,0, 0, false);
        woosim4InchFormatter.print(TotalGetValues,Align.right,1, 0, false);

        woosim4InchFormatter.print("มูลค่าซองที่ใช้ไป",Align.left,0, 0, false);
        woosim4InchFormatter.print(TotalChangeValues,Align.right,4, 0, false);


        //Edit By Kriangkrai
        woosim4InchFormatter.print(footer,Align.left,1, 0, true);
        woosim4InchFormatter.print("..................... \r\nลายเซ็นลูกค้า   ",Align.right,4, 0, true);
        headerPrinter.printFooter(footer);

        try {
            woosim.printBitmap("/sdcard/images/woosim.bmp");
        } catch (IOException e) {
            e.printStackTrace();
        }
        woosim.controlCommand(lf, lf.length);

        byte[] ff = {0};
        woosim.controlCommand(ff, 1);

        woosim.printSpool(true);
        cardData = null;
        //qwer
    }

    private void Print_3inch(int billingTypeNumber, String billType) {

        saleCode = sessionManager.getSaleCode();
        saleUserFullName = sessionManager.getUserFullName();

        byte[] init = {0x1b, '@'};
        byte[] align_right = {27, 97, 50};
        byte[] align_left = {27, 97, 48};
        byte[] lf = {0x0a}; //0x0a          textViewVat.setText(String.format("%.2f",getVatAmount(totalPrice)));

        woosim.controlCommand(init, init.length);

        String regData = "";
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
        Date dt = new Date();

        if(fromPage.equals("HistoricalOrderDetailsFragment")){
            String[] cutHisDate = historyDate.split("/");
            regData = String.format("%02d", Integer.parseInt(cutHisDate[0]))+"/"+String.format("%02d", Integer.parseInt(cutHisDate[1]))+"/"+cutHisDate[2];
        }else {
            regData = dateFormat.format(dt);
        }
        headerPrinter.printFPlusHeader(true);

/*        woosim.saveSpool(TIS_620, "            (สำเนาบิลเงินสด/ใบกำกับภาษี)\r\n\r\n", 0, false);
*/

        String header = "";
        String footer = "";

        if ("V".equalsIgnoreCase(billType)) {
            switch (billingTypeNumber) {
                case 1:
                    header = "                          (บิลเงินสด/ใบกำกับภาษี)";
                    break;

                case 2:
                case 3:
                    header = "                        (สำเนาบิลเงินสด/ใบกำกับภาษี)";
                    break;

                default:
                    header = "";
                    break;
            }

            footer = "ลงชื่อผู้รับเงิน " + saleCode + "-" + saleUserFullName;
        } else if ("C".equalsIgnoreCase(billType)) {
            switch (billingTypeNumber) {
                case 1:
                    header = "                          (ต้นฉบับใบเสร็จรับเงิน)";
                    break;

                case 2:
                    header = "                        (ต้นฉบับใบกำกับภาษี/ใบส่งของ)";
                    break;

                case 3:
                    header = "                     (สำเนาใบกำกับภาษี/สำเนาใบส่งของ)";
                    break;

                default:
                    header = "";
                    break;
            }

            footer = "ลงชื่อผู้รับเงิน " + saleCode + "-" + saleUserFullName;
        }

        woosim.saveSpool(TIS_620, header + "\r\n\r\n", 0, false);

        //woosim.saveSpool(TIS_620, "เลขที่ " + invoiceNumber + " " + "                                    วันที่ "+regData+"\r\n", 0, false);
        woosim.saveSpool(TIS_620, "เลขที่ ", 0, false);
        woosim.saveSpool(TIS_620, invoiceNumber, 0, true);
        woosim.saveSpool(TIS_620, "                                     วันที่ ", 0, false);
        woosim.saveSpool(TIS_620, regData + "\r\n", 0, true);

        woosim.saveSpool(TIS_620, "ชื่อลูกค้า " + storeName, 0, false);
        woosim.controlCommand(align_right, align_right.length);
        woosim.saveSpool(TIS_620, "รหัส " + storeID + "\r\n", 0, false);
        woosim.controlCommand(align_left, align_left.length);
        woosim.saveSpool(TIS_620, "ที่อยู่ " + storeAddress + "\r\n", 0, false);
        //TODO Replace mock storeTaxID with actual
        woosim.saveSpool(TIS_620, "เลขประจำตัวผู้เสียภาษี " + storeTax + "\r\n\r\n", 0, false);

        //ส่วนลด
        // 4 sp2 - 12 sp2 - 10 sp2 - 8 sp2 - 8 sp2
        woosim.saveSpool(TIS_620, "    สินค้า                        จำนวน       ราคา    ส่วนลด         รวม\r\n", 0, false);

        int counter = 1;

        for (OrderedProductPack anOrderedProduct : orderedProductList) {

            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(String.valueOf(counter), 2, "L") + "  ", 0, false);
            String restProductName = generateProductName(anOrderedProduct.getName(), billType);
            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(String.valueOf(anOrderedProduct.getAmount()), 3, "R") + " ", 0, false);
            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(anOrderedProduct.getUnit(), 5 + woosim4InchFormatter.getNoOfUpperLowerChar(anOrderedProduct.getUnit()), "L") + "  ", 0, false);
            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(String.valueOf(df.format(Double.parseDouble(anOrderedProduct.getPrice()) /* Integer.parseInt(anOrderedProduct.getAmount())*/)), 7, "R") + "  ", 0, false);
            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(anOrderedProduct.getDiscount(), 7, "R") + "  ", 0, false);
            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(String.valueOf(df.format((Double.parseDouble(anOrderedProduct.getPrice()) * Integer.parseInt(anOrderedProduct.getAmount())) - Double.parseDouble(anOrderedProduct.getDiscount()))), 10, "R") + "\r\n", 0, false);

            while (!restProductName.equals("")) {
                restProductName = generateRestProductName(restProductName, billType);
            }

            counter++;
        }

        woosim4InchFormatter.print("", Align.left, 2, 0, false);
        //Edit By Kriangkrai
        double truePrice = (Double.parseDouble(totalPrice)*100)/107;
        //double truePrice = (Double.parseDouble(totalPrice));
        BigDecimal aa = new BigDecimal(truePrice);
        BigDecimal divideA = aa.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);
        woosim4InchFormatter.printBetween("รวมมูลค่าสินค้า", String.valueOf(changeFormat.format(divideA)), 0, false);
        woosim4InchFormatter.printBetween("ส่วนลด", discount, 0, false);

        /*if (!selectedVatType.equals("implicit")) {
            if (!vat.equals("")) {*/
        BigDecimal bb = new BigDecimal(Double.parseDouble(totalPrice) - truePrice);
        BigDecimal divideB = bb.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);
        woosim4InchFormatter.printBetween("ภาษีมูลค่าเพิ่ม 7%", String.valueOf(changeFormat.format(divideB)), 0, false);
            /*}
        }*/
        BigDecimal dis1 = new BigDecimal(Double.parseDouble(Discount1));
        BigDecimal dis_1 = dis1.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);
        woosim4InchFormatter.printBetween(PercentDiscount, String.valueOf(changeFormat.format(dis_1)), 0, false);

        BigDecimal dis2 = new BigDecimal(Double.parseDouble(Discount2));
        BigDecimal dis_2 = dis2.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);
        woosim4InchFormatter.printBetween("ส่วนลดร้านค้า", String.valueOf(changeFormat.format(dis_2)), 0, false);


        BigDecimal netP = new BigDecimal(Double.parseDouble(netPrice)-Double.parseDouble(Discount1)-Double.parseDouble(Discount2));
        BigDecimal net_P = netP.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);
        woosim4InchFormatter.printBetween("จำนวนเงินรวมสุทธิ", String.valueOf(changeFormat.format(net_P)), 0, false);
        thaiBathText = new ThaiBaht().getText(String.valueOf(changeFormat.format(net_P)));
        woosim4InchFormatter.print("(" + thaiBathText + ")", Align.end, 3, 0, true);

        //Edit By Kasemtan
        headerPrinter.printFooter(footer);

        try {
            woosim.printBitmap("/sdcard/images/woosim.bmp");
        } catch (IOException e) {
            e.printStackTrace();
        }
        woosim.controlCommand(lf, lf.length);
        woosim.controlCommand(lf, lf.length);


        byte[] ff = {0};
        woosim.controlCommand(ff, 1);

        woosim.printSpool(true);
        cardData = null;

    }

    private void Print_4inch_12T(int billingTypeNumber, String billType) {

        saleCode = sessionManager.getSaleCode();
        saleUserFullName = sessionManager.getUserFullName();

        byte[] init = {0x1b, '@'};
        byte[] lf = {0x0a}; //0x0a          textViewVat.setText(String.format("%.2f",getVatAmount(totalPrice)));

        woosim.controlCommand(init, init.length);

        String regData = "";
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
        Date dt = new Date();

        if(fromPage.equals("HistoricalOrderDetailsFragment")){
            String[] cutHisDate = historyDate.split("/");
            regData = String.format("%02d", Integer.parseInt(cutHisDate[0]))+"/"+String.format("%02d", Integer.parseInt(cutHisDate[1]))+"/"+cutHisDate[2];
        }else {
            regData = dateFormat.format(dt);
        }

        /*Bitmap bitmap = ((BitmapDrawable) imageView.getDrawable()).getBitmap();
        woosim.printBitmap(R.drawable.fplus_logo, 1);*/
        headerPrinter.print12TradingHeader(true);

        /*        woosim.saveSpool(TIS_620, "            (สำเนาบิลเงินสด/ใบกำกับภาษี)\r\n\r\n", 0, false);
         */

        String header = "";
        String footer = "";

        if ("V".equalsIgnoreCase(billType)) {
            switch (billingTypeNumber) {
                case 1:
                    header = "(บิลเงินสด/ใบกำกับภาษี)";
                    break;

                case 2:
                case 3:
                    header = "(สำเนาบิลเงินสด/ใบกำกับภาษี)";
                    break;

                default:
                    header = "";
                    break;
            }

            footer = "ลงชื่อผู้รับเงิน " + saleCode + "-" + saleUserFullName;
        } else if ("C".equalsIgnoreCase(billType)) {
            switch (billingTypeNumber) {
                case 1:
                    header = "(ต้นฉบับใบเสร็จรับเงิน)";
                    break;

                case 2:
                    header = "(ต้นฉบับใบกำกับภาษี/ใบส่งของ)";
                    break;

                case 3:
                    header = "(สำเนาใบกำกับภาษี/สำเนาใบส่งของ)";
                    break;

                default:
                    header = "";
                    break;
            }

            footer = "ลงชื่อผู้รับเงิน " + saleCode + "-" + saleUserFullName;
        }


        woosim4InchFormatter.print(header,Align.center,1, 0, true);
        woosim4InchFormatter.print("เอกสารออกเป็นชุด",Align.center,2, 0, true);

        headerPrinter.printStoreDetail(storeID, invoiceNumber, storeName, regData, storeAddress, true, storeTax);
        woosim4InchFormatter.print("    รายการสินค้า                  จำนวน       ราคา    ส่วนลด         รวม",Align.left,1, 0, true);
        int counter = 1;
        for (OrderedProductPack item: orderedProductList) {
            woosim4InchFormatter.print(StringHelper.generateStringWithSuitableSpace(String.valueOf(counter), 2, "L") + "  ",Align.left,0, 0, false);
            String restProductName = generateProductName(item.getName(), billType);
            // concat product detail
            String productBillDetail = StringHelper.generateStringWithSuitableSpace(String.valueOf(item.getAmount()), 3, "R") // Amount
                    + StringHelper.generateStringWithSuitableSpace(item.getUnit(), 5 + woosim4InchFormatter.getNoOfUpperLowerChar(item.getUnit()), "L") // Unit
                    + StringHelper.generateStringWithSuitableSpace(String.valueOf(df.format(Double.parseDouble(item.getPrice()) /* Integer.parseInt(anOrderedProduct.getAmount())*/)), 10, "R") // Price
                    + StringHelper.generateStringWithSuitableSpace(item.getDiscount(), 9, "R") // Discount
                    + StringHelper.generateStringWithSuitableSpace(String.valueOf(df.format((Double.parseDouble(item.getPrice()) * Integer.parseInt(item.getAmount())) - Double.parseDouble(item.getDiscount()))), 12, "R"); // Total Price

            woosim4InchFormatter.print(productBillDetail,Align.left,1, 0, false);

            while (!restProductName.equals("")) {
                restProductName = generateRestProductName(restProductName, billType);
            }

            counter++;
        }

        //woosim.controlCommand(lf, lf.length);

        woosim4InchFormatter.print("",Align.left,2, 0, false);

        //Edit By Kriangkrai
        double truePrice = (Double.parseDouble(totalPrice)*100)/107;
        //double truePrice = (Double.parseDouble(totalPrice));
        BigDecimal aa = new BigDecimal(truePrice);
        BigDecimal divideA = aa.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);
        woosim4InchFormatter.printBetween("รวมมูลค่าสินค้า", changeFormat.format(divideA), 0, false);
        woosim4InchFormatter.printBetween("ส่วนลด", discount, 0, false);
        /*if (!selectedVatType.equals("implicit")) {
            if (!vat.equals("")) {*/
        BigDecimal bb = new BigDecimal(Double.parseDouble(totalPrice) - truePrice);
        BigDecimal divideB = bb.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);
        woosim4InchFormatter.printBetween("ภาษีมูลค่าเพิ่ม 7%", String.valueOf(changeFormat.format(divideB)), 0, false);
            /*}
        }*/
        BigDecimal dis1 = new BigDecimal(Double.parseDouble(Discount1));
        BigDecimal dis_1 = dis1.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);
        woosim4InchFormatter.printBetween(PercentDiscount, String.valueOf(changeFormat.format(dis_1)), 0, false);


        BigDecimal dis2 = new BigDecimal(Double.parseDouble(Discount2));
        BigDecimal dis_2 = dis2.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);
        woosim4InchFormatter.printBetween("ส่วนลดร้านค้า", String.valueOf(changeFormat.format(dis_2)), 0, false);


        BigDecimal netP = new BigDecimal(Double.parseDouble(netPrice)-Double.parseDouble(Discount1)-Double.parseDouble(Discount2));
        BigDecimal net_P = netP.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);
        woosim4InchFormatter.printBetween("จำนวนเงินรวมสุทธิ", String.valueOf(changeFormat.format(net_P)), 0, false);

        thaiBathText = new ThaiBaht().getText(String.valueOf(changeFormat.format(net_P)));
        woosim4InchFormatter.print("(" + thaiBathText + ")",Align.end,4, 0, false);

        headerPrinter.printFooter(footer);

        try {
            woosim.printBitmap("/sdcard/images/woosim.bmp");
        } catch (IOException e) {
            e.printStackTrace();
        }
        woosim.controlCommand(lf, lf.length);
        woosim.controlCommand(lf, lf.length);


        byte[] ff = {0};
        woosim.controlCommand(ff, 1);

        woosim.printSpool(true);
        cardData = null;

    }

    /// Create By Kriangkrai ///
    private void PrintCut(){
        byte[] init = {0x1b, '@'};

        woosim.controlCommand(init, init.length);
        woosim4InchFormatter.print("----------------------------- ตัดตามรอยปะ ----------------------------",Align.center,4, 0, true);
    }
    ////////////////////////////

    private void Print_4inch_Ch_12T (int billingTypeNumber, String billType,
                                 String bill_number, String bill_date, String store_id, String store_name, String store_address, String difference, String selectTypeName,
                                 List<String> list_id, List<String> list_name, List<String> list_amount, List<String> list_unit,
                                 List<String> list_status, List<String> list_lot, List<String> list_price, String total_price, String pointer) {

        saleCode = sessionManager.getSaleCode();
        saleUserFullName = sessionManager.getUserFullName();
        //thaiBathText = new ThaiBaht().getText(total_price);
        Double newTotalPrice = 0.0;


        byte[] init = {0x1b, '@'};
        byte[] lf = {0x0a};

        woosim.controlCommand(init, init.length);


        headerPrinter.print12TradingHeader(true);

        String header = "";
        String footer = "";

        switch (billingTypeNumber) {
            case 1:
                if(pointer.equals("get")){
                    header = "(ใบลดหนี้)";
                }else if(pointer.equals("change")){
                    header = "(บิลเงินสด/ใบกำกับภาษี)";
                }else{
                    header = "(ใบลดหนี้/ใบกำกับภาษี)";
                }

                break;

            case 2:
                if(pointer.equals("get")){
                    header = "(สำเนาใบลดหนี้)";
                }else if(pointer.equals("change")){
                    header = "(สำเนาบิลเงินสด/ใบกำกับภาษี)";
                }else{
                    header = "(สำเนาใบลดหนี้/ใบกำกับภาษี)";
                }
                break;

            case 3:
                header = "(สำเนาบิลเงินสด/ใบกำกับภาษี)";
                break;

            default:
                header = "";
                break;
        }

        footer = "ลงชื่อผู้รับเงิน " + saleCode + "-" + saleUserFullName;


        woosim4InchFormatter.print(header,Align.center,1, 0, true);
        woosim4InchFormatter.print("เอกสารออกเป็นชุด",Align.center,2, 0, true);
        headerPrinter.printStoreDetail(store_id, bill_number, store_name, bill_date, store_address, true, "-");
        //////////////////

        if (pointer.equals("get")) {
            woosim4InchFormatter.print("สินค้าที่รับมาจากร้านค้า",Align.left,1, 0, true);
        } else if (pointer.equals("change")) {
            woosim4InchFormatter.print("สินค้าที่เปลี่ยนให้ร้านค้า",Align.left,1, 0, true);
        }else if (pointer.equals("give")){
            woosim4InchFormatter.print(selectTypeName,Align.left,1, 0, true);
        }else{
            woosim4InchFormatter.print("รายการสินค้า",Align.left,1, 0, true);
        }

        woosim4InchFormatter.print("---------------------------------------------------------------------",Align.left,1, 0, true);
        woosim4InchFormatter.print("    รายการสินค้า                  จำนวน       ราคา    ส่วนลด         รวม",Align.left,1, 0, true);

        int counter = 1;

        for (int i=0; i<=list_id.size()-1; i++) {
            String status = "";
            if(pointer.equals("get")){
                if(list_status.get(i).equals("3")){
                    status = "เสีย";
                }else{
                    status = "ดี";
                }
            }

            // format Price
            BigDecimal pr = new BigDecimal(Double.parseDouble(list_price.get(i)));
            BigDecimal formPrice = pr.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);

            // foemat Price/Unit
            BigDecimal pu = new BigDecimal(Double.parseDouble(list_price.get(i))/Double.parseDouble(list_amount.get(i)));
            BigDecimal formPricePerUnit = pu.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);

            woosim4InchFormatter.print(StringHelper.generateStringWithSuitableSpace(String.valueOf(counter), 2, "L") + "  ",Align.left,0, 0, false);
            String restProductName="";
            if(pointer.equals("get")) {
                restProductName = generateProductName(list_name.get(i) + " #" + status + "/" + list_lot.get(i) + "#", billType);
            }else{
                restProductName = generateProductName(list_name.get(i), billType);
            }

            String productDetail = StringHelper.generateStringWithSuitableSpace(list_amount.get(i), 3, "R") + " "  +
                    StringHelper.generateStringWithSuitableSpace(list_unit.get(i), 5 + woosim4InchFormatter.getNoOfUpperLowerChar(list_unit.get(i)), "L") + "  " +
                    StringHelper.generateStringWithSuitableSpace(String.valueOf(changeFormat.format(formPricePerUnit)), 7, "R") + "  " +
                    StringHelper.generateStringWithSuitableSpace("0.00", 7, "R") + "  " +
                    StringHelper.generateStringWithSuitableSpace(String.valueOf(changeFormat.format(formPrice)), 10, "R");

            woosim4InchFormatter.print(productDetail, Align.left,1, 0, false);

            while (!restProductName.equals("")) {
                restProductName = generateRestProductName(restProductName, billType);
            }
            newTotalPrice += Double.parseDouble(list_price.get(i));
            counter++;
        }

        //woosim.controlCommand(lf, lf.length);
        woosim4InchFormatter.print("",Align.left,2, 0, false);


        //Edit By Kriangkrai
        double truePrice = (newTotalPrice*100)/107;
        BigDecimal aa = new BigDecimal(truePrice);
        BigDecimal divideA = aa.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);
        woosim4InchFormatter.printBetween("รวมมูลค่าสินค้า", String.valueOf(changeFormat.format(divideA)), 0, false);

        woosim4InchFormatter.printBetween("ส่วนลด", "0.00", 0, false);


        BigDecimal bb = new BigDecimal(newTotalPrice - truePrice);
        BigDecimal divideB = bb.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);
        woosim4InchFormatter.printBetween("ภาษีมูลค่าเพิ่ม 7%", String.valueOf(changeFormat.format(divideB)), 0, false);


        BigDecimal tt = new BigDecimal(newTotalPrice);
        BigDecimal divideT = tt.divide(new BigDecimal(1),4, RoundingMode.HALF_UP);
        woosim4InchFormatter.printBetween("จำนวนเงินรวมสุทธิ", String.valueOf(changeFormat.format(divideT)), 0, false);

        thaiBathText = new ThaiBaht().getText(String.valueOf(newTotalPrice));
        woosim4InchFormatter.print("(" + thaiBathText + ")",Align.end,2, 0, true);

        if(pointer.equals("change")) {
            woosim4InchFormatter.printBetween("ค่าส่วนต่างที่ต้องชำระ", difference, 0, false);
            thaiBathText = new ThaiBaht().getText(difference);
            woosim4InchFormatter.print("(" + thaiBathText + ")",Align.end,4, 0, true);
        }else {
            woosim4InchFormatter.print("",Align.left,2, 0, false);
        }

        //Edit By Kasemtan
        headerPrinter.printFooter(footer);

        try {
            woosim.printBitmap("/sdcard/images/woosim.bmp");
        } catch (IOException e) {
            e.printStackTrace();
        }
        woosim.controlCommand(lf, lf.length);

        byte[] ff = {0};
        woosim.controlCommand(ff, 1);

        woosim.printSpool(true);
        cardData = null;
    }

    private void Print_4inch_Ch_12T_Log (int billingTypeNumber, String billType,
                                      String bill_number, String bill_date, String store_id, String store_name, String store_address, String difference, String selectTypeName,
                                      List<String> list_id, List<String> list_name, List<String> list_amount, List<String> list_unit,
                                      List<String> list_status, List<String> list_lot, List<String> list_price, String total_price, String pointer) {

        saleCode = sessionManager.getSaleCode();
        saleUserFullName = sessionManager.getUserFullName();
        //thaiBathText = new ThaiBaht().getText(total_price);
        Double newTotalPrice = 0.0;


        byte[] init = {0x1b, '@'};
        byte[] align_right = {27, 97, 50};
        byte[] align_left = {27, 97, 48};
        byte[] lf = {0x0a};

        //woosim.controlCommand(init, init.length);

        Log.e("LogPrint", "                           บริษัท วันทูเทรดดิ้ง จำกัด\r\n");
        Log.e("LogPrint", "                 582/9 ซ.สุขุมวิท 63 ถ.สุขุมวิท แขวงคลองตันเหนือ\r\n");
        Log.e("LogPrint", "                       เขตวัฒนา กรุงเทพมหานคร 10110\r\n");
        Log.e("LogPrint", "                  โทร.(02)391-3200  โทรสาร.(02)391-7895\r\n");
        Log.e("LogPrint", "                     เลขประจำตัวผู้เสียภาษี 0105563063410\r\n");
        Log.e("LogPrint", "                        ออกใบกำกับภาษีโดยสำนักงานใหญ่\r\n");
        Log.e("LogPrint", "                             เอกสารออกเป็นชุด\r\n");

        String header = "";
        String footer = "";

        switch (billingTypeNumber) {
            case 1:
                if(pointer.equals("get")){
                    header = "                                (ใบลดหนี้)";
                }else if(pointer.equals("change")){
                    header = "                               (ใบกำกับภาษี)";
                }else{
                    header = "                      (ใบลดหนี้/ใบกำกับภาษี)";
                }

                break;

            case 2:
                if(pointer.equals("get")){
                    header = "                             (สำเนาใบลดหนี้)";
                }else if(pointer.equals("change")){
                    header = "                            (สำเนาใบกำกับภาษี)";
                }else{
                    header = "                      (สำเนาใบลดหนี้/ใบกำกับภาษี)";
                }
                break;

            case 3:
                header = "                        (สำเนาบิลเงินสด/ใบกำกับภาษี)";
                break;

            default:
                header = "";
                break;
        }

        footer = "ลงชื่อผู้รับเงิน " + saleCode + "-" + saleUserFullName;


        Log.e("LogPrint", header + "\r\n\r\n");
        Log.e("LogPrint", "รหัสลูกค้า "+store_id);
        Log.e("LogPrint", "=====>");
        //woosim.controlCommand(align_right, align_right.length);
        Log.e("LogPrint", "เลขที่ " + bill_number+ "\r\n");
        Log.e("LogPrint", "<=====");
        //woosim.controlCommand(align_left, align_left.length);
        Log.e("LogPrint", "ชื่อลูกค้า " + store_name);
        Log.e("LogPrint", "=====>");
        //woosim.controlCommand(align_right, align_right.length);
        Log.e("LogPrint", "วันที่ "+bill_date);
        Log.e("LogPrint", "<=====");
        //woosim.controlCommand(align_left, align_left.length);
        Log.e("LogPrint", "\r\n");
        Log.e("LogPrint", "ที่อยู่ " + store_address+ "\r\n");
        Log.e("LogPrint", "เลขประจำตัวผู้เสียภาษี -\r\n\r\n");

        //////////////////

        if (pointer.equals("get")) {
            Log.e("LogPrint", "สินค้าที่รับมาจากร้านค้า\r\n");
        } else if (pointer.equals("change")) {
            Log.e("LogPrint", "สินค้าที่เปลี่ยนให้ร้านค้า\r\n");
        }else if (pointer.equals("give")){
            Log.e("LogPrint", selectTypeName+"\r\n");
        }else{
            Log.e("LogPrint", "รายการสินค้า\r\n");
        }
        Log.e("LogPrint", "---------------------------------------------------------------------\r\n");
        Log.e("LogPrint", "    สินค้า                        จำนวน       ราคา    ส่วนลด         รวม\r\n");

        int counter = 1;

        for (int i=0; i<=list_id.size()-1; i++) {
            String status = "";
            if(pointer.equals("get")){
                if(list_status.get(i).equals("3")){
                    status = "เสีย";
                }else{
                    status = "ดี";
                }
            }

            // format Price
            BigDecimal pr = new BigDecimal(Double.parseDouble(list_price.get(i)));
            BigDecimal formPrice = pr.divide(new BigDecimal(1),4,4);

            // foemat Price/Unit
            BigDecimal pu = new BigDecimal(Double.parseDouble(list_price.get(i))/Double.parseDouble(list_amount.get(i)));
            BigDecimal formPricePerUnit = pu.divide(new BigDecimal(1),4,4);

            Log.e("LogPrint", StringHelper.generateStringWithSuitableSpace(String.valueOf(counter), 2, "L") + "  ");
            String restProductName="";
            if(pointer.equals("get")) {
                restProductName = generateProductName_Log(list_name.get(i) + " #" + status + "/" + list_lot.get(i) + "#", billType);
            }else{
                restProductName = generateProductName_Log(list_name.get(i), billType);
            }
            Log.e("LogPrint", StringHelper.generateStringWithSuitableSpace(list_amount.get(i), 3, "R") + " ");
            Log.e("LogPrint", StringHelper.generateStringWithSuitableSpace(list_unit.get(i), 5 + woosim4InchFormatter.getNoOfUpperLowerChar(list_unit.get(i)), "L") + "  ");
            Log.e("LogPrint", StringHelper.generateStringWithSuitableSpace(String.valueOf(changeFormat.format(formPricePerUnit)), 7, "R") + "  ");
            Log.e("LogPrint", StringHelper.generateStringWithSuitableSpace("0.00", 7, "R") + "  ");
            Log.e("LogPrint", StringHelper.generateStringWithSuitableSpace(String.valueOf(changeFormat.format(formPrice)), 10, "R") + "\r\n");

            while (!restProductName.equals("")) {
                restProductName = generateRestProductName_Log(restProductName, billType);
            }
            newTotalPrice += Double.parseDouble(list_price.get(i));
            counter++;
        }

        //woosim.controlCommand(lf, lf.length);
        Log.e("LogPrint", "\r\n\r\n");

        Log.e("LogPrint", "<=====");
        //woosim.controlCommand(align_left, align_left.length);
        Log.e("LogPrint", "รวมมูลค่าสินค้า ");
        Log.e("LogPrint", "=====>");
        //woosim.controlCommand(align_right, align_right.length);

        //Edit By Kriangkrai
        double truePrice = (newTotalPrice*100)/107;
        BigDecimal aa = new BigDecimal(truePrice);
        BigDecimal divideA = aa.divide(new BigDecimal(1),4,4);
        Log.e("LogPrint", String.valueOf(changeFormat.format(divideA)) + "\r\n");

        Log.e("LogPrint", "<=====");
        //woosim.controlCommand(align_left, align_left.length);
        Log.e("LogPrint", "ส่วนลด ");
        Log.e("LogPrint", "=====>");
        //woosim.controlCommand(align_right, align_right.length);
        Log.e("LogPrint", "0.00" + "\r\n"); //TODO this value is a discount from promotion ท้ายบิล

        BigDecimal bb = new BigDecimal(newTotalPrice - truePrice);
        BigDecimal divideB = bb.divide(new BigDecimal(1),4,4);
        Log.e("LogPrint", "<=====");
        //woosim.controlCommand(align_left, align_left.length);
        Log.e("LogPrint", "ภาษีมูลค่าเพิ่ม 7%");
        Log.e("LogPrint", "=====>");
        //woosim.controlCommand(align_right, align_right.length);
        Log.e("LogPrint", String.valueOf(changeFormat.format(divideB)) + "\r\n");

        Log.e("LogPrint", "<=====");
        //woosim.controlCommand(align_left, align_left.length);
        Log.e("LogPrint", "จำนวนมูลค่ารวมสุทธิ ");
        Log.e("LogPrint", "=====>");
        //woosim.controlCommand(align_right, align_right.length);
        BigDecimal tt = new BigDecimal(newTotalPrice);
        BigDecimal divideT = tt.divide(new BigDecimal(1),4,4);
        Log.e("LogPrint", String.valueOf(changeFormat.format(divideT)) + "\r\n");
        thaiBathText = new ThaiBaht().getText(String.valueOf(newTotalPrice));
        Log.e("LogPrint", "(" + thaiBathText + ")" + "\r\n\r\n");

        if(pointer.equals("change")) {
            Log.e("LogPrint", "<=====");
            //woosim.controlCommand(align_left, align_left.length);
            Log.e("LogPrint", "ค่าส่วนต่างที่ต้องชำระ ");
            Log.e("LogPrint", "=====>");
            //woosim.controlCommand(align_right, align_right.length);
            Log.e("LogPrint", difference + "\r\n");
            thaiBathText = new ThaiBaht().getText(difference);
            Log.e("LogPrint", "(" + thaiBathText + ")" + "\r\n\r\n");
        }

        Log.e("LogPrint", "\r\n\r\n");
        Log.e("LogPrint", "<=====");
        //woosim.controlCommand(align_left, align_left.length);

        //Edit By Kriangkrai
        Log.e("LogPrint", "\r\n");
        Log.e("LogPrint", footer);
        Log.e("LogPrint", "=====>");
        //woosim.controlCommand(align_right, align_right.length);
        Log.e("LogPrint", "..................... \r\nลายเซ็นลูกค้า   ");
        Log.e("LogPrint", "\r\n\r\n\r\n\r\n");

        /*try {
            woosim.printBitmap("/sdcard/images/woosim.bmp");
        } catch (IOException e) {
            e.printStackTrace();
        }
        woosim.controlCommand(lf, lf.length);
        woosim.controlCommand(lf, lf.length);

        byte[] ff = {0};
        woosim.controlCommand(ff, 1);

        woosim.printSpool(true);
        cardData = null;*/
    }


    /// Create By Kriangkrai ///
    private void PrintCut_Log(){
        byte[] init = {0x1b, '@'};
        byte[] align_right = {27, 97, 50};
        byte[] align_left = {27, 97, 48};
        byte[] lf = {0x0a}; //0x0a          textViewVat.setText(String.format("%.2f",getVatAmount(totalPrice)));

        //woosim.controlCommand(init, init.length);

        Log.e("LogPrint", "----------------------------- ตัดตามรอยปะ ----------------------------\r\n");
        Log.e("LogPrint", "\r\n\r\n\r\n");
    }

    private void Print_3inch_Ch (int billingTypeNumber, String billType,
                                  String bill_number, String bill_date, String store_id, String store_name, String store_address, String difference, String selectTypeName,
                                  List<String> list_id, List<String> list_name, List<String> list_amount, List<String> list_unit,
                                  List<String> list_status, List<String> list_lot, List<String> list_price, String total_price, String pointer) {

        saleCode = sessionManager.getSaleCode();
        saleUserFullName = sessionManager.getUserFullName();
        //thaiBathText = new ThaiBaht().getText(total_price);
        Double newTotalPrice = 0.0;


        byte[] init = {0x1b, '@'};
        byte[] align_right = {27, 97, 50};
        byte[] align_left = {27, 97, 48};
        byte[] lf = {0x0a};

        woosim.controlCommand(init, init.length);
        headerPrinter.printFPlusHeader(true);

        String header = "";
        String footer = "";

        switch (billingTypeNumber) {
            case 1:
                if(pointer.equals("get")){
                    header = "                               (ใบลดหนี้)";
                }else if(pointer.equals("change")){
                    header = "                              (ใบกำกับภาษี)";
                }else{
                    header = "                      (ใบลดหนี้/ใบกำกับภาษี)";
                }

                break;

            case 2:
                if(pointer.equals("get")){
                    header = "                             (สำเนาใบลดหนี้)";
                }else if(pointer.equals("change")){
                    header = "                           (สำเนาใบกำกับภาษี)";
                }else{
                    header = "                      (สำเนาใบลดหนี้/ใบกำกับภาษี)";
                }
                break;

            case 3:
                header = "                        (สำเนาบิลเงินสด/ใบกำกับภาษี)";
                break;

            default:
                header = "";
                break;
        }

        footer = "ลงชื่อผู้รับเงิน " + saleCode + "-" + saleUserFullName;

        woosim.saveSpool(TIS_620, header + "\r\n\r\n", 0, false);
        woosim.saveSpool(TIS_620, "เลขที่ ", 0, false);
        woosim.saveSpool(TIS_620, bill_number, 0, true);
        woosim.saveSpool(TIS_620, "                                     วันที่ ", 0, false);
        woosim.saveSpool(TIS_620, bill_date + "\r\n", 0, true);

        woosim.saveSpool(TIS_620, "ชื่อลูกค้า " + store_name, 0, false);
        woosim.controlCommand(align_right, align_right.length);
        woosim.saveSpool(TIS_620, "รหัส " + store_id + "\r\n", 0, false);
        woosim.controlCommand(align_left, align_left.length);
        woosim.saveSpool(TIS_620, "ที่อยู่ " + store_address + "\r\n", 0, false);
        //TODO Replace mock storeTaxID with actual
        woosim.saveSpool(TIS_620, "เลขประจำตัวผู้เสียภาษี -\r\n\r\n", 0, false);

        if (pointer.equals("get")) {
            woosim.saveSpool(TIS_620, "สินค้าที่รับมาจากร้านค้า\r\n", 0, true);
        } else if (pointer.equals("change")) {
            woosim.saveSpool(TIS_620, "สินค้าที่เปลี่ยนให้ร้านค้า\r\n", 0, true);
        }else if (pointer.equals("give")){
            woosim.saveSpool(TIS_620, selectTypeName+"\r\n", 0, true);
        }else{
            woosim.saveSpool(TIS_620, "รายการสินค้า\r\n", 0, true);
        }
        woosim.saveSpool(TIS_620, "---------------------------------------------------------------------\r\n", 0, false);
        woosim.saveSpool(TIS_620, "    สินค้า                        จำนวน       ราคา    ส่วนลด         รวม\r\n", 0, false);

        int counter = 1;

        for (int i=0; i<=list_id.size()-1; i++) {
            String status = "";
            if(pointer.equals("get")){
                if(list_status.get(i).equals("3")){
                    status = "เสีย";
                }else{
                    status = "ดี";
                }
            }

            // format Price
            BigDecimal pr = new BigDecimal(Double.parseDouble(list_price.get(i)));
            BigDecimal formPrice = pr.divide(new BigDecimal(1),4,4);

            // foemat Price/Unit
            BigDecimal pu = new BigDecimal(Double.parseDouble(list_price.get(i))/Double.parseDouble(list_amount.get(i)));
            BigDecimal formPricePerUnit = pu.divide(new BigDecimal(1),4,4);

            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(String.valueOf(counter), 2, "L") + "  ", 0, false);
            String restProductName="";
            if(pointer.equals("get")) {
                restProductName = generateProductName(list_name.get(i) + " #" + status + "/" + list_lot.get(i) + "#", billType);
            }else{
                restProductName = generateProductName(list_name.get(i), billType);
            }
            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(list_amount.get(i), 3, "R") + " ", 0, false);
            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(list_unit.get(i), 5 + woosim4InchFormatter.getNoOfUpperLowerChar(list_unit.get(i)), "L") + "  ", 0, false);
            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(String.valueOf(changeFormat.format(formPricePerUnit)), 7, "R") + "  ", 0, false);
            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace("0.00", 7, "R") + "  ", 0, false);
            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(String.valueOf(changeFormat.format(formPrice)), 10, "R") + "\r\n", 0, false);

            while (!restProductName.equals("")) {
                restProductName = generateRestProductName(restProductName, billType);
            }
            newTotalPrice += Double.parseDouble(list_price.get(i));
            counter++;
        }

        woosim.controlCommand(lf, lf.length);
        woosim.saveSpool(TIS_620, "\r\n\r\n", 0, false);

        woosim.controlCommand(align_left, align_left.length);
        woosim.saveSpool(TIS_620, "รวมมูลค่าสินค้า ", 0, false);
        woosim.controlCommand(align_right, align_right.length);

        //Edit By Kriangkrai
        double truePrice = (newTotalPrice*100)/107;
        BigDecimal aa = new BigDecimal(truePrice);
        BigDecimal divideA = aa.divide(new BigDecimal(1),4,4);
        woosim.saveSpool(TIS_620, String.valueOf(changeFormat.format(divideA)) + "\r\n", 0, false);

        woosim.controlCommand(align_left, align_left.length);
        woosim.saveSpool(TIS_620, "ส่วนลด ", 0, false);
        woosim.controlCommand(align_right, align_right.length);
        woosim.saveSpool(TIS_620, "0.00" + "\r\n", 0, false); //TODO this value is a discount from promotion ท้ายบิล

        BigDecimal bb = new BigDecimal(newTotalPrice - truePrice);
        BigDecimal divideB = bb.divide(new BigDecimal(1),4,4);
        woosim.controlCommand(align_left, align_left.length);
        woosim.saveSpool(TIS_620, "ภาษีมูลค่าเพิ่ม 7%", 0, false);
        woosim.controlCommand(align_right, align_right.length);
        woosim.saveSpool(TIS_620, String.valueOf(changeFormat.format(divideB)) + "\r\n", 0, false);

        woosim.controlCommand(align_left, align_left.length);
        woosim.saveSpool(TIS_620, "จำนวนมูลค่ารวมสุทธิ ", 0, false);
        woosim.controlCommand(align_right, align_right.length);
        BigDecimal tt = new BigDecimal(newTotalPrice);
        BigDecimal divideT = tt.divide(new BigDecimal(1),4,4);
        woosim.saveSpool(TIS_620, String.valueOf(changeFormat.format(divideT)) + "\r\n", 0, true);
        thaiBathText = new ThaiBaht().getText(String.valueOf(newTotalPrice));
        woosim.saveSpool(TIS_620, "(" + thaiBathText + ")" + "\r\n\r\n", 0, true);

        if(pointer.equals("change")) {
            woosim.controlCommand(align_left, align_left.length);
            woosim.saveSpool(TIS_620, "ค่าส่วนต่างที่ต้องชำระ ", 0, false);
            woosim.controlCommand(align_right, align_right.length);
            woosim.saveSpool(TIS_620, difference + "\r\n", 0, true);
            thaiBathText = new ThaiBaht().getText(difference);
            woosim.saveSpool(TIS_620, "(" + thaiBathText + ")" + "\r\n\r\n", 0, true);
        }

        //Edit By Kasemtan
        woosim4InchFormatter.print("", Align.left, 3, 0, false);
        headerPrinter.printFooter(footer);

        try {
            woosim.printBitmap("/sdcard/images/woosim.bmp");
        } catch (IOException e) {
            e.printStackTrace();
        }
        woosim.controlCommand(lf, lf.length);
        woosim.controlCommand(lf, lf.length);

        byte[] ff = {0};
        woosim.controlCommand(ff, 1);

        woosim.printSpool(true);
        cardData = null;
    }

    //Log Print
    private void LogPrint_3inch_Ch (int billingTypeNumber, String billType,
                                 String bill_number, String bill_date, String store_id, String store_name, String store_address, String difference, String selectTypeName,
                                 List<String> list_id, List<String> list_name, List<String> list_amount, List<String> list_unit,
                                 List<String> list_status, List<String> list_lot, List<String> list_price, String total_price, String pointer) {

        saleCode = sessionManager.getSaleCode();
        saleUserFullName = sessionManager.getUserFullName();
        //thaiBathText = new ThaiBaht().getText(total_price);
        Double newTotalPrice = 0.0;


        byte[] init = {0x1b, '@'};
        byte[] align_right = {27, 97, 50};
        byte[] align_left = {27, 97, 48};
        byte[] lf = {0x0a};

        //woosim.controlCommand(init, init.length);

        String header = "";
        String footer = "";

        switch (billingTypeNumber) {
            case 1:
                if(pointer.equals("get")){
                    header = "                               (ใบลดหนี้)";
                }else if(pointer.equals("change")){
                    header = "                              (ใบกำกับภาษี)";
                }else{
                    header = "                      (ใบลดหนี้/ใบกำกับภาษี)";
                }

                break;

            case 2:
                if(pointer.equals("get")){
                    header = "                             (สำเนาใบลดหนี้)";
                }else if(pointer.equals("change")){
                    header = "                           (สำเนาใบกำกับภาษี)";
                }else{
                    header = "                      (สำเนาใบลดหนี้/ใบกำกับภาษี)";
                }
                break;

            case 3:
                header = "                        (สำเนาบิลเงินสด/ใบกำกับภาษี)";
                break;

            default:
                header = "";
                break;
        }

        footer = "ลงชื่อผู้รับเงิน " + saleCode + "-" + saleUserFullName;

        /*Log.e("LogPrint", "0000000000000000000"+header+"0000000000000000000");
        Log.e("LogPrint", "เลขที่ " + bill_number);
        Log.e("LogPrint", "วันที่ " + bill_date + "\n");

        Log.e("LogPrint", "ชื่อลูกค้า " + store_name);
        Log.e("LogPrint", "รหัส " + store_id);
        Log.e("LogPrint", "ที่อยู่ " + store_address);
        Log.e("LogPrint", "เลขประจำตัวผู้เสียภาษี - \n");
*/
        if (pointer.equals("get")) {

            Log.e("LogPrint", "สินค้าที่รับมาจากร้านค้า\n");
        } else if (pointer.equals("change")) {
            Log.e("LogPrint", "สินค้าที่เปลี่ยนให้ร้านค้า\n");
        }else if (pointer.equals("give")){
            Log.e("LogPrint", selectTypeName+"\n");
        }else{
            Log.e("LogPrint", "รายการสินค้า\n");
        }

        Log.e("LogPrint", "-------------------------------------------");

        int counter = 1;

        for (int i=0; i<=list_id.size()-1; i++) {
            String status = "";
            if(pointer.equals("get")){
                if(list_status.get(i).equals("3")){
                    status = "เสีย";
                }else{
                    status = "ดี";
                }
            }

            // format Price
            BigDecimal pr = new BigDecimal(Double.parseDouble(list_price.get(i)));
            BigDecimal formPrice = pr.divide(new BigDecimal(1),4,4);

            // foemat Price/Unit
            BigDecimal pu = new BigDecimal(Double.parseDouble(list_price.get(i))/Double.parseDouble(list_amount.get(i)));
            BigDecimal formPricePerUnit = pu.divide(new BigDecimal(1),4,4);


            String restProductName = "";
            if(pointer.equals("get")) {
                restProductName = generateProductName_Log(list_name.get(i) + " #" + status + "/" + list_lot.get(i) + "#", billType);
            }else{
                restProductName = generateProductName_Log(list_name.get(i), billType);
            }

            Log.e("LogPrint", restProductName);
            Log.e("LogPrint", list_amount.get(i)+" "+list_unit.get(i));

            Log.e("LogPrint", "ราคา "+String.valueOf(changeFormat.format(formPricePerUnit)));

            Log.e("LogPrint", "รวม "+String.valueOf(changeFormat.format(formPrice))+"\n\n");


            while (!restProductName.equals("")) {
                restProductName = generateRestProductName_Log(restProductName, billType);
            }

            newTotalPrice += Double.parseDouble(list_price.get(i));
            counter++;
        }

        //Edit By Kriangkrai
        double truePrice = (newTotalPrice*100)/107;
        BigDecimal aa = new BigDecimal(truePrice);
        BigDecimal divideA = aa.divide(new BigDecimal(1),4,4);

        Log.e("LogPrint", "///////////////////////////////");

        Log.e("LogPrint", "รวมมูลค่าสินค้า " + String.valueOf(changeFormat.format(divideA)));
        Log.e("LogPrint", "ส่วนลด 0.00");

        BigDecimal bb = new BigDecimal(newTotalPrice - truePrice);
        BigDecimal divideB = bb.divide(new BigDecimal(1),4,4);

        Log.e("LogPrint", "ภาษีมูลค่าเพิ่ม 7% " + String.valueOf(changeFormat.format(divideB)));


        BigDecimal tt = new BigDecimal(newTotalPrice);
        BigDecimal divideT = tt.divide(new BigDecimal(1),4,4);
        thaiBathText = new ThaiBaht().getText(String.valueOf(newTotalPrice));

        Log.e("LogPrint", "จำนวนมูลค่ารวมสุทธิ " + String.valueOf(changeFormat.format(divideT)));
        Log.e("LogPrint", "(" + thaiBathText + ")");

        if(pointer.equals("change")) {
            thaiBathText = new ThaiBaht().getText(difference);

            Log.e("LogPrint", "ค่าส่วนต่างที่ต้องชำระ " + difference);
            Log.e("LogPrint", "(" + thaiBathText + ")\n");
        }

        /*Log.e("LogPrint", footer);
        Log.e("LogPrint", "..................... \nลายเซ็นลูกค้า   ");*/
    }

    ///666
    private void Print_3inch_Tf (int billingTypeNumber, String billType,
                                 String tf_no, String tf_date, String tf_destination, String tf_type,
                                 List<String> list_id, List<String> list_name, List<String> list_amount, List<String> list_unit) {

        saleCode = sessionManager.getSaleCode();
        saleUserFullName = sessionManager.getUserFullName();
        saleArea = sessionManager.getAreaCode();

        if (saleArea.startsWith("N/E") || saleArea.startsWith("NE")){
            saleAreaText = "อิสาน";
        }else if (saleArea.startsWith("N")){
            saleAreaText = "เหนือ";
        }else if (saleArea.startsWith("C")){
            saleAreaText = "กลาง";
        }else if (saleArea.startsWith("E")){
            saleAreaText = "ตะวันออก";
        }else if (saleArea.startsWith("S")){
            saleAreaText = "ใต้";
        }else if (saleArea.startsWith("BKK") || saleArea.startsWith("B")){
            saleAreaText = "กทม";
        }else{
            saleAreaText = saleArea;
        }

        byte[] init = {0x1b, '@'};
        byte[] align_right = {27, 97, 50};
        byte[] align_left = {27, 97, 48};
        byte[] lf = {0x0a};

        woosim.controlCommand(init, init.length);
        headerPrinter.printFPlusHeader(true);

        String header = "";
        String footer = "";

        switch (billingTypeNumber) {
            case 1:
                if(billType.equals("Transfer")) {
                    header = "                             (ใบรับโอนสินค้า)";
                }else {
                    header = "                             (ใบขอเบิกสินค้า)";
                }
                break;

            case 2:
                if(billType.equals("Transfer")) {
                    header = "                           (สำเนาใบรับโอนสินค้า)";
                }else {
                    header = "                           (สำเนาใบขอเบิกสินค้า)";
                }
                break;

            default:
                header = "";
                break;
        }

        if(billType.equals("Transfer")) {
            footer = ".....................\r\n" + saleCode + "-" + saleUserFullName+"\r\n       ผู้รับโอน";
        }else{
            footer = ".....................\r\n" + saleCode + "-" + saleUserFullName+"\r\n       ผู้ขอเบิก";
        }

        woosim.saveSpool(TIS_620, header + "\r\n\r\n", 0, false);
        woosim.saveSpool(TIS_620, tf_type+"\r\n", 0, true);
        woosim.saveSpool(TIS_620, "เลขที่ ", 0, false);
        woosim.saveSpool(TIS_620, tf_no, 0, true);

        if(billType.equals("Transfer")) {
            woosim.saveSpool(TIS_620, "                                     วันที่ ", 0, false);
            woosim.saveSpool(TIS_620, tf_date_conv + "\r\n", 0, true);
        }else{
            //แก้วันที่ตรงนี้
            woosim.saveSpool(TIS_620, "                                  วันที่ ", 0, false);
            woosim.saveSpool(TIS_620, wd_date_conv + "\r\n", 0, true);
        }

        woosim.saveSpool(TIS_620, "พนักงานขาย " + saleUserFullName, 0, false);
        woosim.controlCommand(align_right, align_right.length);
        woosim.saveSpool(TIS_620, "เขต " + saleAreaText + "\r\n", 0, false);
        woosim.controlCommand(align_left, align_left.length);

        if(billType.equals("Transfer")){
            woosim.saveSpool(TIS_620, "รับโอนจาก " + tf_destination + "\r\n\r\n", 0, false);
            woosim.saveSpool(TIS_620, "สินค้าที่รับโอน\r\n", 0, true);
        }else{
            woosim.saveSpool(TIS_620, "สถานที่จัดส่ง " + tf_destination + "\r\n", 0, false);
            woosim.saveSpool(TIS_620, "วันที่จัดส่ง " + wd_delivery_date + "\r\n\r\n", 0, false);
            woosim.saveSpool(TIS_620, "สินค้าที่ขอเบิก\r\n", 0, true);
        }

        woosim.saveSpool(TIS_620, "---------------------------------------------------------------------\r\n", 0, false);
        woosim.saveSpool(TIS_620, "    สินค้า                                                   จำนวน     \r\n", 0, false);

        int counter = 1;

        for (int i=0; i<=list_id.size()-1; i++) {

            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(String.valueOf(counter), 2, "L") + "  ", 0, false);
            String restProductName = generateProductName(list_name.get(i), billType);
            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(list_amount.get(i), 3, "R") + " ", 0, false);
            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(list_unit.get(i), 5 + woosim4InchFormatter.getNoOfUpperLowerChar(list_unit.get(i)), "L") + "\r\n", 0, false);

            while (!restProductName.equals("")) {
                restProductName = generateRestProductName(restProductName, billType);
            }

            counter++;
        }

        woosim.controlCommand(lf, lf.length);
        woosim.saveSpool(TIS_620, "\r\n\r\n", 0, false);

        //Edit By Kriangkrai
        woosim.saveSpool(TIS_620, "\r\n", 0, false);
        woosim.saveSpool(TIS_620, footer, 0, true);
        /*woosim.controlCommand(align_right, align_right.length);
        woosim.saveSpool(TIS_620, "..................... \r\nsaleUserFullName    \r\nลายเซ็นผู้รับโอน  ", 0, true);*/
        woosim.saveSpool(TIS_620, "\r\n\r\n\r\n\r\n", 0, true);

        try {
            woosim.printBitmap("/sdcard/images/woosim.bmp");
        } catch (IOException e) {
            e.printStackTrace();
        }
        woosim.controlCommand(lf, lf.length);
        woosim.controlCommand(lf, lf.length);

        byte[] ff = {0};
        woosim.controlCommand(ff, 1);

        woosim.printSpool(true);
        cardData = null;
        //qwer
    }


    private void Print_4inch_Tf_12T (int billingTypeNumber, String billType,
                                 String tf_no, String tf_date, String tf_destination, String tf_type,
                                 List<String> list_id, List<String> list_name, List<String> list_amount, List<String> list_unit) {

        saleCode = sessionManager.getSaleCode();
        saleUserFullName = sessionManager.getUserFullName();
        saleArea = sessionManager.getAreaCode();

        if (saleArea.startsWith("N/E") || saleArea.startsWith("NE")){
            saleAreaText = "อิสาน";
        }else if (saleArea.startsWith("N")){
            saleAreaText = "เหนือ";
        }else if (saleArea.startsWith("C")){
            saleAreaText = "กลาง";
        }else if (saleArea.startsWith("E")){
            saleAreaText = "ตะวันออก";
        }else if (saleArea.startsWith("S")){
            saleAreaText = "ใต้";
        }else if (saleArea.startsWith("BKK") || saleArea.startsWith("B")){
            saleAreaText = "กทม";
        }else{
            saleAreaText = saleArea;
        }

        byte[] init = {0x1b, '@'};
        byte[] lf = {0x0a};

        woosim.controlCommand(init, init.length);

        headerPrinter.print12TradingHeader(true);

        String header;
        String footer;

        switch (billingTypeNumber) {
            case 1:
                if(billType.equals("Transfer")) {
                    header = "(ใบรับโอนสินค้า)";
                }else {
                    header = "(ใบขอเบิกสินค้า)";
                }
                break;

            case 2:
                if(billType.equals("Transfer")) {
                    header = "(สำเนาใบรับโอนสินค้า)";
                }else {
                    header = "(สำเนาใบขอเบิกสินค้า)";
                }
                break;

            default:
                header = "";
                break;
        }

        if(billType.equals("Transfer")) {
            footer = ".....................\r\n" + saleCode + "-" + saleUserFullName+"\r\n       ผู้รับโอน";
        }else{
            footer = ".....................\r\n" + saleCode + "-" + saleUserFullName+"\r\n       ผู้ขอเบิก";
        }

        woosim4InchFormatter.print(header,Align.center,1, 0, true);
        woosim4InchFormatter.print("เอกสารออกเป็นชุด",Align.center,2, 0, true);
        woosim4InchFormatter.print(tf_type,Align.left,1, 0, true);
        //println("เลขที่ "+tf_no,"left",0, 0, false);

        if(billType.equals("Transfer")) {

            woosim4InchFormatter.print("เลขที่ "+tf_no+"                                     "+"วันที่ "+tf_date_conv,Align.left,0, 0, false);
            //println("วันที่ "+tf_date_conv,Align.right,1, 0, false);
        }else{
            woosim4InchFormatter.print("เลขที่ "+tf_no+"                                        "+"วันที่ "+wd_date_conv,Align.left,0, 0, false);
            //println("วันที่ "+wd_date_conv,Align.right,1, 0, false);
        }

        woosim4InchFormatter.print("พนักงานขาย " + saleUserFullName,Align.left,0, 0, false);
        woosim4InchFormatter.print("เขต " + saleAreaText,Align.right,1, 0, false);

        if(billType.equals("Transfer")){
            woosim4InchFormatter.print("รับโอนจาก " + tf_destination,Align.left,2, 0, false);
            woosim4InchFormatter.print("สินค้าที่รับโอน",Align.left,1, 0, true);
        }else{
            woosim4InchFormatter.print("สถานที่จัดส่ง " + tf_destination,Align.left,1, 0, false);
            woosim4InchFormatter.print("วันที่จัดส่ง " + wd_delivery_date,Align.left,2, 0, false);
            woosim4InchFormatter.print("สินค้าที่ขอเบิก",Align.left,1, 0, true);
        }

        woosim4InchFormatter.print("---------------------------------------------------------------------",Align.left,1, 0, false);
        woosim4InchFormatter.print("    รายการสินค้า                                             จำนวน     ",Align.left,1, 0, true);

        int counter = 1;

        for (int i=0; i<=list_id.size()-1; i++) {

            woosim4InchFormatter.print(StringHelper.generateStringWithSuitableSpace(String.valueOf(counter), 2, "L") + "  ",Align.left,0, 0, false);
            String restProductName = generateProductName(list_name.get(i), billType);
            String productReview = StringHelper.generateStringWithSuitableSpace(list_amount.get(i), 3, "R") + " " +
                    StringHelper.generateStringWithSuitableSpace(list_unit.get(i), 5 + woosim4InchFormatter.getNoOfUpperLowerChar(list_unit.get(i)), "L");
            woosim4InchFormatter.print(productReview, Align.left,1, 0, false);
            while (!restProductName.equals("")) {
                restProductName = generateRestProductName(restProductName, billType);
            }

            counter++;
        }

        woosim4InchFormatter.print("",Align.left,3, 0, false);

        //Edit By Kriangkrai
        woosim4InchFormatter.print(footer,Align.left,4, 0, false);

        try {
            woosim.printBitmap("/sdcard/images/woosim.bmp");
        } catch (IOException e) {
            e.printStackTrace();
        }
        woosim.controlCommand(lf, lf.length);
        woosim.controlCommand(lf, lf.length);

        byte[] ff = {0};
        woosim.controlCommand(ff, 1);

        woosim.printSpool(true);
        cardData = null;
        //qwer
    }

    private void Print_3inch_Give(int billingTypeNumber, String billType){
        saleCode = sessionManager.getSaleCode();
        saleUserFullName = sessionManager.getUserFullName();
        //thaiBathText = new ThaiBaht().getText(netPrice);

        byte[] init = {0x1b, '@'};
        byte[] align_right = {27, 97, 50};
        byte[] align_left = {27, 97, 48};
        byte[] lf = {0x0a}; //0x0a          textViewVat.setText(String.format("%.2f",getVatAmount(totalPrice)));

        woosim.controlCommand(init, init.length);
        headerPrinter.printFPlusHeader(true);

        String header = "";
        switch (billingTypeNumber) {
            case 1:
                header = "                          (บิลเงินสด/ใบกำกับภาษี)";
                break;

            case 2:
                header = "                        (สำเนาบิลเงินสด/ใบกำกับภาษี)";
                break;

            case 3:
                header = "                        (สำเนาบิลเงินสด/ใบกำกับภาษี)";
                break;

            default:
                header = "";
                break;
        }
        String footer = "..................... \r\n      ลายเซ็นลูกค้า";

        woosim.saveSpool(TIS_620, header + "\r\n\r\n", 0, false);
        woosim.saveSpool(TIS_620, "\r\n\r\n", 0, true);
        woosim.saveSpool(TIS_620, ""+selectTypeName+"\r\n", 0, true);

        woosim.saveSpool(TIS_620, "เลขที่ ", 0, false);
        woosim.saveSpool(TIS_620, ex_no, 0, true);
        woosim.saveSpool(TIS_620, "                                     วันที่ ", 0, false);
        woosim.saveSpool(TIS_620, ex_date_conv+"\r\n", 0, true);

        woosim.saveSpool(TIS_620, "พนักงานขาย " + saleUserFullName, 0, false);
        woosim.controlCommand(align_right, align_right.length);
        woosim.saveSpool(TIS_620, "เขต "+sessionManager.getAreaCode()+"\r\n", 0, false);

        woosim.controlCommand(align_left, align_left.length);
        woosim.saveSpool(TIS_620, "ชื่อร้านค้า " + store_name, 0, false);
        woosim.saveSpool(TIS_620, "  ที่อยู่ " + store_address + "\r\n\r\n", 0, false);

        woosim.saveSpool(TIS_620, " สินค้าที่ให้ร้านค้า\r\n", 0, true);
        woosim.saveSpool(TIS_620, "---------------------------------------------------------------------\r\n", 0, false);
        woosim.saveSpool(TIS_620, "    ชื่อสินค้า                                             จำนวน\r\n", 0, true);

        for(int i=0; i<=giveIDList.size()-1; i++) {
            woosim.saveSpool(TIS_620, String.valueOf(i+1), 0, false);
            String restProductName = generateProductName(giveNameList.get(i), billType);
            woosim.saveSpool(TIS_620, giveAmountList.get(i), 0, false);
            woosim.saveSpool(TIS_620, giveUnitList.get(i), 0, false);

//            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(String.valueOf(i+1), 2, "L") + "  ", 0, false);
//            String restProductName = generateProductName(giveNameList.get(i), billType);
//            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(giveAmountList.get(i), 8, "R") + " ", 0, false);
//            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(giveUnitList.get(i), 0 , "L") + "  \r\n", 0, false);

            while(!restProductName.equals(""))
            {
                restProductName = generateRestProductName(restProductName, billType);
            }
        }
        woosim.saveSpool(TIS_620, "---------------------------------------------------------------------\r\n\r\n", 0, false);

        woosim.saveSpool(TIS_620, "\r\n\r\n\r\n", 0, true);
        woosim.saveSpool(TIS_620, footer + "\r\n\r\n\r\n\r\n", 0, true);

        try {
            woosim.printBitmap("/sdcard/images/woosim.bmp");
        } catch (IOException e) {
            e.printStackTrace();
        }
        woosim.controlCommand(lf, lf.length);
        woosim.controlCommand(lf, lf.length);


        byte[] ff = {0};
        woosim.controlCommand(ff, 1);

        woosim.printSpool(true);
        cardData = null;
    }


    private String generateProductName_Log(String productName, String billType) {
        String productName_return_value = productName;
        int productName_length = productName.length();
        int max=0;
        if(billType.equals("Ch")){max=25;}
        else if(billType.equals("Give")){max=25;}
        else if(billType.equals("Transfer")){max=53;}
        else if(billType.equals("Withdraws")){max=53;}
        else if(billType.equals("Collect")){max=35;}
        else if(billType.equals("Give2")){max=35;}
        else{max=25;}

        int oneChar = 0;
        if (productName_length <= max) {

            // นับตัวอักษรที่ไม่ใช่ Upper/Lower
            for (int k=0; k<=productName_length-1; k++){
                char a = productName.charAt(k);
                for(int u=0; u<=allCharacter.size()-1;u++){
                    if(allCharacter.get(u).equals(String.valueOf(a))){
                        oneChar+=1;
                    }
                }
            }

            for (int i = oneChar; i < max; i++) {
                productName_return_value += " ";
            }

            if(oneChar<max){
                Log.e("LogPrint", productName_return_value + " ");
            }else{
                Log.e("LogPrint", productName_return_value + " ");
            }


            return "";
        } else {
            Log.e("LogPrint", StringHelper.generateStringWithSuitableSpace(productName_return_value.substring(0, (max+1)),
                    (max+1) + woosim4InchFormatter.getNoOfUpperLowerChar(productName_return_value.substring(0, (max+1))), "L"
                    ));

            return productName_return_value.substring(max+1);
        }
    }

    private String generateRestProductName_Log(String restProductName, String billType) {
        String leftPadding = "    ";

        int restOneChar= 0;

        int restProductName_length = restProductName.length();
        int max=0;
        if(billType.equals("Ch")){max=25; leftPadding = "    ";}
        else if(billType.equals("Give")){max=25; leftPadding = "    ";}
        else if(billType.equals("Transfer")){max=53; leftPadding = "    ";}
        else if(billType.equals("Withdraws")){max=53; leftPadding = "    ";}
        else if(billType.equals("Collect")){max=35; leftPadding = "    ";}
        else if(billType.equals("Give2")){max=35; leftPadding = "    ";}
        else{max=25; leftPadding = "    ";}

        if (restProductName_length <= max) {

            // นับตัวอักษรที่ไม่ใช่ Upper/Lower
            for (int k=0; k<=restProductName_length-1; k++){
                char a = restProductName.charAt(k);
                for(int u=0; u<=allCharacter.size()-1;u++){
                    if(allCharacter.get(u).equals(String.valueOf(a))){
                        restOneChar+=1;
                    }
                }
            }

            for (int i = restOneChar; i <= max; i++) {
                restProductName += " ";
            }
            Log.e("LogPrint", leftPadding + restProductName + "\r\n");
            return "";
        } else {
            Log.e("LogPrint", leftPadding + StringHelper.generateStringWithSuitableSpace(restProductName.substring(0, (max+1)),
                    (max+1) + woosim4InchFormatter.getNoOfUpperLowerChar(restProductName.substring(0, (max+1))), "L"
            ) + "\r\n");
            return restProductName.substring(max+1);
        }

    }

    private String generateProductName(String productName, String billType) {
        String productName_return_value = productName;
        int productName_length = productName.length();
        int max=0;
        if(billType.equals("Ch")){max=25;}
        else if(billType.equals("Give")){max=25;}
        else if(billType.equals("Transfer")){max=53;}
        else if(billType.equals("Withdraws")){max=53;}
        else if(billType.equals("Collect")){max=35;}
        else if(billType.equals("Give2")){max=35;}
        else{max=25;}

        int oneChar = 0;
        if (productName_length <= max) {

            // นับตัวอักษรที่ไม่ใช่ Upper/Lower
            for (int k=0; k<=productName_length-1; k++){
                char a = productName.charAt(k);
                for(int u=0; u<=allCharacter.size()-1;u++){
                    if(allCharacter.get(u).equals(String.valueOf(a))){
                        oneChar+=1;
                    }
                }
            }

            for (int i = oneChar; i < max; i++) {
                productName_return_value += " ";
            }

            if(oneChar<max){
                woosim.saveSpool(TIS_620, productName_return_value + " ", 0, false);
            }else{
                woosim.saveSpool(TIS_620, productName_return_value + " ", 0, false);
            }


            return "";
        } else {
            woosim.saveSpool(TIS_620, StringHelper.generateStringWithSuitableSpace(productName_return_value.substring(0, (max+1)),
                            (max+1) + woosim4InchFormatter.getNoOfUpperLowerChar(productName_return_value.substring(0, (max+1))), "L"
                    ),
                    0, false);

            return productName_return_value.substring(max+1);
        }
    }

    private String generateRestProductName(String restProductName, String billType) {
        String leftPadding = "    ";

        int restOneChar= 0;

        int restProductName_length = restProductName.length();
        int max=0;
        if(billType.equals("Ch")){max=25; leftPadding = "    ";}
        else if(billType.equals("Give")){max=25; leftPadding = "    ";}
        else if(billType.equals("Transfer")){max=53; leftPadding = "    ";}
        else if(billType.equals("Withdraws")){max=53; leftPadding = "    ";}
        else if(billType.equals("Collect")){max=35; leftPadding = "    ";}
        else if(billType.equals("Give2")){max=35; leftPadding = "    ";}
        else{max=25; leftPadding = "    ";}

        if (restProductName_length <= max) {

            // นับตัวอักษรที่ไม่ใช่ Upper/Lower
            for (int k=0; k<=restProductName_length-1; k++){
                char a = restProductName.charAt(k);
                for(int u=0; u<=allCharacter.size()-1;u++){
                    if(allCharacter.get(u).equals(String.valueOf(a))){
                        restOneChar+=1;
                    }
                }
            }

            for (int i = restOneChar; i <= max; i++) {
                restProductName += " ";
            }
            woosim.saveSpool(TIS_620, leftPadding + restProductName + "\r\n", 0, false);
            return "";
        } else {
            woosim.saveSpool(TIS_620, leftPadding + StringHelper.generateStringWithSuitableSpace(restProductName.substring(0, (max+1)),
                    (max+1) + woosim4InchFormatter.getNoOfUpperLowerChar(restProductName.substring(0, (max+1))), "L"
            ) + "\r\n", 0, false);
            return restProductName.substring(max+1);
        }

    }

    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            // When discovery finds a device
            if (BluetoothDevice.ACTION_FOUND.equals(action)) {
                // Get the BluetoothDevice object from the Intent
                BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                // If it's already paired, skip it, because it's been listed already
                if (device.getBondState() != BluetoothDevice.BOND_BONDED) {
                    mNewDevicesArrayAdapter.add(device.getName() + "\n" + device.getAddress());
                }
                // When discovery is finished, change the Activity title
            } else if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(action)) {
                getActivity().setProgressBarIndeterminateVisibility(false);
                //getActivity().setTitle(R.string.select_device);
                if (mNewDevicesArrayAdapter.getCount() == 0) {
                    String noDevices = getResources().getText(R.string.none_found).toString();
                    mNewDevicesArrayAdapter.add(noDevices);
                }
            }
        }

    };


    /**
     * Start device discover with the BluetoothAdapter
     */
    private void doDiscovery(View v) {
        // Indicate scanning in the title
        getActivity().setProgressBarIndeterminateVisibility(true);
        getActivity().setTitle(R.string.scanning);
        // Turn on sub-title for new devices
        v.findViewById(R.id.title_new_devices).setVisibility(View.VISIBLE);
        // If we're already discovering, stop it
        if (mBtAdapter.isDiscovering()) {
            mBtAdapter.cancelDiscovery();
        }
        // Request discover from BluetoothAdapter
        mBtAdapter.startDiscovery();
    }

    /*public void myOnKeyDown(int key_code){
        Toast.makeText(getActivity(), "BackKeyDown", Toast.LENGTH_SHORT).show();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event){
        if(keyCode == KeyEvent.KEYCODE_BACK){

            ((PastEventListFragment)fragments.get(0)).myOnKeyDown(keyCode);
        }
        return super.onKeyDown(keyCode, event);
    }

    @Override
    public void onBackPressed(){
        Toast.makeText(getActivity(), "BackKeyDown", Toast.LENGTH_SHORT).show();
    }*/

}

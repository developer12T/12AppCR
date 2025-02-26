package com.tohome.fplus.util.printinghelpers;
 
import com.woosim.bt.WoosimPrinter;
 
import java.util.ArrayList;
 
public class WoosimFormatter {
    // add other format here, contact Kasemtan Tevasirichokchai for more information
    public static final int fourInchLineLength = 69;
    private final int lineLength;
    private final WoosimPrinter woosim;
    private final ArrayList<Character> vowelAndToneMark;
    private final static String TIS_620 = "TIS-620";
 
    public WoosimFormatter(WoosimPrinter woosim, int lineLength) {
        this.woosim = woosim;
        this.lineLength = lineLength;
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
    }
 
    public void printBetween(String frontText, String backText, int fontValue, boolean emphasis) {
        int frontTextSpaces = lineLength /2 + getNoOfUpperLowerChar(frontText);
        int backTextSpaces = lineLength /2 + getNoOfUpperLowerChar(backText);
        String formattedString = String.format("%-"+frontTextSpaces+"s%"+backTextSpaces+"s", frontText, backText);
        woosim.saveSpool(TIS_620, formattedString, fontValue, emphasis);
        woosim.saveSpool(TIS_620, "\r\n", fontValue, emphasis);
    }
 
    public void print(String text, Align align, int newLine, int fontValue, boolean emphasis){
 
        // 1 Line = 69 Text
        byte[] align_right = {27, 97, 50};
        byte[] align_left = {27, 97, 48};
 
        if(align == Align.end){ //ชิดขวาสุด บังคับขึ้นบรรทัดใหม่
            String text_count = text;
            for(int j=0; j<69-text.length()+getNoOfUpperLowerChar(text); j++){
                text_count = " "+text_count;
            }
            woosim.controlCommand(align_left, align_left.length);
            woosim.saveSpool(TIS_620, text_count, fontValue, emphasis);
            if(newLine == 0){newLine=newLine+1;}
 
        }else if (align == Align.right){ //ไล่จากขวามาซ้าย *หากภาษาไทยมีสระบน/ล่าง จะเพี้ยนทันที
            woosim.controlCommand(align_right, align_right.length);
            woosim.saveSpool(TIS_620, text, fontValue, emphasis);
 
        }else if (align == Align.center){ //ตรงกลาง
            for(int j=0; j<69-text.length()+getNoOfUpperLowerChar(text); j++){
                text = " "+text;
            }
            woosim.controlCommand(align_left, align_left.length);
            woosim.saveSpool(TIS_620, text, fontValue, emphasis);
 
        }else { // default case = left ไล่จากซ้ายไปขวา
            woosim.controlCommand(align_left, align_left.length);
            woosim.saveSpool(TIS_620, text, fontValue, emphasis);
        }
 
        for(int i=0; i<newLine; i++){
            woosim.saveSpool(TIS_620, "\r\n", fontValue, emphasis);
        }
    }
 
    public int getNoOfUpperLowerChar(String string) {
        int counter = 0;
        for (char aVowelOrToneMark : vowelAndToneMark) {
            for (char c : string.toCharArray()) {
                if (aVowelOrToneMark == c) {
                    counter++;
                }
            }
        }
        return counter;
    }
}
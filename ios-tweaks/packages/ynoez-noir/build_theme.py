from pathlib import Path
from PIL import Image, ImageDraw
import math

OUT = Path("ios-tweaks/packages/ynoez-noir/var/jb/Library/Themes/ynoez noir.theme/IconBundles")
OUT.mkdir(parents=True, exist_ok=True)
S = 180
W = (255, 255, 255, 255)
B = (0, 0, 0, 255)

def draw_icon(kind):
    im = Image.new("RGBA", (S, S), B)
    d = ImageDraw.Draw(im)
    def ln(p, width=9): d.line(p, fill=W, width=width, joint="curve")
    def oval(b, width=9): d.ellipse(b, outline=W, width=width)
    def rect(b, radius=12, width=9): d.rounded_rectangle(b, radius=radius, outline=W, width=width)
    if kind == "phone":
        rect((58, 30, 122, 150), 14); d.ellipse((84, 128, 96, 140), fill=W); ln([(78,45),(102,45)],5)
    elif kind == "messages":
        rect((30, 38, 150, 126), 22); d.polygon([(55,120),(45,146),(83,126)], fill=W)
        for x in (68,90,112): d.ellipse((x-4,78,x+4,86), fill=W)
    elif kind == "safari":
        oval((32,32,148,148)); ln([(107,59),(92,94),(59,121)],9); ln([(74,120),(89,86),(121,60)],5)
    elif kind == "camera":
        rect((28,55,152,135), 15); d.rounded_rectangle((52,40,88,60), radius=5, fill=W)
        oval((67,72,113,118)); d.ellipse((83,88,97,102), fill=W)
    elif kind == "photos":
        for b in ((39,39,91,91),(89,39,141,91),(39,89,91,141),(89,89,141,141)): rect(b,18,8)
    elif kind == "settings":
        oval((49,49,131,131),10); oval((78,78,102,102),8)
        for a in range(0,360,45):
            p1=(90+math.cos(math.radians(a))*43,90+math.sin(math.radians(a))*43)
            p2=(90+math.cos(math.radians(a))*61,90+math.sin(math.radians(a))*61)
            ln([p1,p2],10)
    elif kind == "music":
        ln([(105,43),(105,120)],10); ln([(105,47),(139,38),(139,111)],9)
        d.ellipse((44,108,88,151), fill=W); d.ellipse((111,101,154,144), fill=W)
    elif kind == "appstore":
        ln([(57,132),(112,42)],11); ln([(82,139),(139,48)],11); ln([(44,98),(136,98)],11)
    elif kind == "mail":
        rect((28,47,152,133),12); ln([(38,59),(90,103),(142,59)],9)
    elif kind == "calendar":
        rect((35,40,145,145),12); ln([(35,72),(145,72)],8); ln([(64,30),(64,57)],9); ln([(116,30),(116,57)],9)
        for x in (63,90,117):
            for y in (94,119): d.ellipse((x-4,y-4,x+4,y+4), fill=W)
    elif kind == "clock":
        oval((32,32,148,148)); ln([(90,51),(90,92),(122,110)],10)
    elif kind == "maps":
        ln([(40,52),(76,38),(112,53),(142,41),(142,128),(110,143),(74,127),(40,141),(40,52)],8)
        ln([(76,39),(76,127)],7); ln([(111,53),(111,142)],7); d.ellipse((82,68,101,87), fill=W)
    elif kind == "notes":
        rect((40,30,140,150),10); 
        for y in (70,94,118): ln([(58,y),(122,y)],6)
    elif kind == "files":
        rect((28,52,152,140),13); ln([(33,67),(70,67),(83,82),(147,82)],8)
    elif kind == "weather":
        oval((43,66,107,130),8); oval((76,45,128,105),8); rect((42,87,139,128),18,8)
        ln([(61,146),(53,158)],6); ln([(94,146),(86,158)],6); ln([(127,146),(119,158)],6)
    elif kind == "youtube":
        rect((25,48,155,132),22); d.polygon([(76,68),(76,112),(115,90)], fill=W)
    return im

icons = {
 "com.apple.mobilephone":"phone",
 "com.apple.MobileSMS":"messages",
 "com.apple.mobilesafari":"safari",
 "com.apple.camera":"camera",
 "com.apple.mobileslideshow":"photos",
 "com.apple.Preferences":"settings",
 "com.apple.Music":"music",
 "com.apple.AppStore":"appstore",
 "com.apple.mobilemail":"mail",
 "com.apple.mobilecal":"calendar",
 "com.apple.mobiletimer":"clock",
 "com.apple.Maps":"maps",
 "com.apple.mobilenotes":"notes",
 "com.apple.DocumentsApp":"files",
 "com.apple.weather":"weather",
 "com.google.ios.youtube":"youtube",
}
for bundle, glyph in icons.items():
    draw_icon(glyph).save(OUT / (bundle + "-large.png"), optimize=True)
print("Generated", len(icons), "black/white 180px icons.")

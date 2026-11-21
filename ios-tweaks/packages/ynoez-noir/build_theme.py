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
    elif kind == "whatsapp":
        oval((34,30,146,142),9); d.arc((47,44,132,128),205,320,fill=W,width=11)
        ln([(59,119),(48,145),(76,133)],9); ln([(68,67),(83,89),(108,105)],9)
    elif kind == "instagram":
        rect((34,34,146,146),25,9); oval((61,61,119,119),8); d.ellipse((119,51,132,64),fill=W)
    elif kind == "tiktok":
        ln([(99,39),(99,112)],12); ln([(99,43),(132,55)],10); d.ellipse((51,101,96,146),fill=W)
    elif kind == "discord":
        rect((31,47,149,132),24,9); arc((53,49,127,110),190,350,8)
        d.ellipse((61,83,78,100),fill=W); d.ellipse((102,83,119,100),fill=W)
    elif kind == "spotify":
        oval((31,31,149,149),9)
        arc((49,58,131,108),205,335,8); arc((54,78,126,119),205,335,7); arc((61,98,119,130),205,335,6)
    elif kind == "telegram":
        d.polygon([(28,84),(151,36),(127,147),(88,112),(68,132),(70,98)],outline=W,fill=None)
        ln([(70,98),(119,62),(88,112)],7)
    elif kind == "x":
        ln([(48,43),(132,137)],11); ln([(132,43),(48,137)],11)
    elif kind == "facebook":
        d.text((53,19),"f",fill=W,stroke_width=3,stroke_fill=W)
    elif kind == "gmail":
        ln([(34,132),(34,54),(90,99),(146,54),(146,132)],10)
        ln([(34,54),(90,99),(146,54)],10)
    elif kind == "chrome":
        oval((30,30,150,150),9); oval((66,66,114,114),8)
        ln([(90,32),(145,61)],7); ln([(36,61),(65,113)],7)
    elif kind == "netflix":
        ln([(49,139),(49,41)],14); ln([(49,41),(131,139)],14); ln([(131,139),(131,41)],14)
    elif kind == "twitch":
        rect((34,35,146,125),8,9); d.polygon([(62,124),(62,145),(86,124)],fill=W)
        rect((64,59,79,92),2,5); rect((101,59,116,92),2,5)
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
 "net.whatsapp.WhatsApp":"whatsapp",
 "com.burbn.instagram":"instagram",
 "com.zhiliaoapp.musically":"tiktok",
 "com.hammerandchisel.discord":"discord",
 "com.spotify.client":"spotify",
 "ph.telegra.Telegraph":"telegram",
 "com.atebits.Tweetie2":"x",
 "com.facebook.Facebook":"facebook",
 "com.google.Gmail":"gmail",
 "com.google.chrome.ios":"chrome",
 "com.netflix.Netflix":"netflix",
 "tv.twitch":"twitch",
}
for bundle, glyph in icons.items():
    draw_icon(glyph).save(OUT / (bundle + "-large.png"), optimize=True)
print("Generated", len(icons), "black/white 180px icons.")

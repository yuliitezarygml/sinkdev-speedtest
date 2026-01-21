import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

# --- Configuration ---
WIDTH, HEIGHT = 1080, 1920
BG_COLOR = (20, 21, 38)      # #141526
CARD_BG = (30, 31, 51)       # #1E1F33
CYAN = (0, 209, 209)         # #00d1d1
CYAN_BRIGHT = (0, 229, 255)  # #00E5FF
PURPLE = (141, 52, 230)      # #8d34e6
PURPLE_BRIGHT = (191, 90, 242)# #BF5AF2
TRACK_COLOR = (22, 32, 50)   # #162032
TEXT_WHITE = (255, 255, 255)
TEXT_GREY = (158, 158, 158)  # Colors.grey
GREEN_PING = (192, 235, 117) # #c0eb75

# Try to load better fonts (Segoe UI is standard on Windows)
try:
    font_reg = "seguiemj.ttf" # Often has symbols too
    font_bold = "seguisb.ttf"
    # Fallbacks
    FONT_HUGE = ImageFont.truetype(font_bold, 140)
    FONT_TITLE = ImageFont.truetype(font_bold, 60)
    FONT_LARGE = ImageFont.truetype(font_reg, 50)
    FONT_MED = ImageFont.truetype(font_reg, 35)
    FONT_SMALL = ImageFont.truetype(font_reg, 28)
except:
    try:
        font_reg = "arial.ttf"
        font_bold = "arialbd.ttf"
        FONT_HUGE = ImageFont.truetype(font_bold, 140)
        FONT_TITLE = ImageFont.truetype(font_bold, 60)
        FONT_LARGE = ImageFont.truetype(font_reg, 50)
        FONT_MED = ImageFont.truetype(font_reg, 35)
        FONT_SMALL = ImageFont.truetype(font_reg, 28)
    except:
        FONT_HUGE = ImageFont.load_default()
        FONT_TITLE = ImageFont.load_default()
        FONT_LARGE = ImageFont.load_default()
        FONT_MED = ImageFont.load_default()
        FONT_SMALL = ImageFont.load_default()

def create_canvas():
    return Image.new("RGB", (WIDTH, HEIGHT), BG_COLOR)

def draw_glow(draw, xy, radius, color):
    # Simulate glow with concentric circles
    r, g, b = color
    for i in range(10):
        alpha = int(100 * (1 - i/10))
        size = radius + i * 2
        x0, y0 = xy[0] - size, xy[1] - size
        x1, y1 = xy[0] + size, xy[1] + size
        draw.ellipse([x0, y0, x1, y1], outline=(r, g, b), width=2)

def draw_gradient_arc(draw, center, radius, start_angle, sweep_angle, color_start, color_end, width=30):
    # Approximating gradient by drawing small segments
    segments = 50
    for i in range(segments):
        ratio = i / segments
        angle = start_angle + (sweep_angle * ratio)
        
        # Interpolate color
        r = int(color_start[0] + (color_end[0] - color_start[0]) * ratio)
        g = int(color_start[1] + (color_end[1] - color_start[1]) * ratio)
        b = int(color_start[2] + (color_end[2] - color_start[2]) * ratio)
        
        draw.arc(
            [center[0]-radius, center[1]-radius, center[0]+radius, center[1]+radius],
            angle, angle + (sweep_angle/segments) + 1, fill=(r,g,b), width=width
        )

def draw_header(draw, title="SPEEDTEST"):
    # Simulated AppBar
    # Icons (History left, Settings right)
    draw.text((40, 60), "≡", fill=TEXT_GREY, font=ImageFont.truetype("arial.ttf", 60) if "arial" in str(FONT_TITLE) else FONT_TITLE) # Menu/History icon placeholder
    
    w = draw.textlength(title, font=FONT_TITLE)
    draw.text(((WIDTH-w)/2, 60), title, fill=TEXT_WHITE, font=FONT_TITLE)
    
    draw.text((WIDTH-90, 60), "⚙", fill=TEXT_GREY, font=ImageFont.truetype("arial.ttf", 50) if "arial" in str(FONT_TITLE) else FONT_TITLE) # Settings

def draw_stat_item(draw, x, y, label, value, unit, icon_char, icon_color):
    # Icon placeholder
    draw.ellipse([x, y, x+40, y+40], outline=icon_color, width=3)
    # Label
    draw.text((x+50, y+5), label, fill=TEXT_GREY, font=FONT_MED)
    # Value
    draw.text((x+50, y+50), value, fill=TEXT_WHITE, font=FONT_LARGE)
    # Unit
    w_val = draw.textlength(value, font=FONT_LARGE)
    draw.text((x+50+w_val+10, y+65), unit, fill=TEXT_GREY, font=FONT_SMALL)

def draw_result_header(draw, x, y, label, value, color, is_download=True):
    # Icon
    draw.ellipse([x, y, x+30, y+30], outline=color, width=2)
    arrow = "↓" if is_download else "↑"
    draw.text((x+8, y-5), arrow, fill=color, font=FONT_MED)
    
    draw.text((x+40, y), label, fill=TEXT_WHITE, font=FONT_MED)
    
    # Value
    w = draw.textlength(value, font=FONT_HUGE)
    # Center text roughly
    draw.text((x-20, y+50), value, fill=TEXT_WHITE, font=FONT_HUGE)
    draw.text((x+30, y+200), "Mbps", fill=TEXT_GREY, font=FONT_MED)
    
    # Underline
    draw.line([x, y+240, x+150, y+240], fill=color, width=4)

# ----------------- SCREEN 1: MAIN (IDLE) -----------------
img1 = create_canvas()
d1 = ImageDraw.Draw(img1)
draw_header(d1)

# Center Circle Button (Start)
cx, cy = WIDTH//2, HEIGHT//2 + 100
r_btn = 180

# Ripple effect
for i in range(3):
    rr = r_btn + (i+1)*40
    d1.ellipse([cx-rr, cy-rr, cx+rr, cy+rr], outline=(0, 209, 209, 50), width=2)

# Main button
d1.ellipse([cx-r_btn, cy-r_btn, cx+r_btn, cy+r_btn], outline=CYAN, width=5)
d1.text((cx-90, cy-30), "START", fill=TEXT_WHITE, font=FONT_TITLE)

# Stats row (Empty)
draw_stat_item(d1, 100, HEIGHT-600, "Ping", "0", "ms", "P", GREEN_PING)
draw_stat_item(d1, WIDTH-400, HEIGHT-600, "Jitter", "0", "ms", "J", "orange")

# Footer (ISP info)
fy = HEIGHT - 250
d1.rectangle([0, fy, WIDTH, HEIGHT], fill=(15, 16, 30))
d1.text((50, fy+30), "Moldtelecom", fill=TEXT_WHITE, font=FONT_LARGE)
d1.text((50, fy+90), "192.168.1.105", fill=TEXT_GREY, font=FONT_MED)
d1.text((50, fy+150), "Server: Orange Moldova", fill=TEXT_WHITE, font=FONT_MED)

img1.save("screen_1_main.png")

# ----------------- SCREEN 2: TESTING (GAUGE) -----------------
img2 = create_canvas()
d2 = ImageDraw.Draw(img2)
draw_header(d2)

# Gauge
gx, gy = WIDTH//2, HEIGHT//2 - 200
gr = 350
# Track
d2.arc([gx-gr, gy-gr, gx+gr, gy+gr], 135, 405, fill=TRACK_COLOR, width=50)

# Progress (Cyan to Purple) - let's say 70%
draw_gradient_arc(d2, (gx, gy), gr, 135, 135+200, CYAN_BRIGHT, PURPLE_BRIGHT, width=50)

# Value in center
speed_val = "85.5"
ws = d2.textlength(speed_val, font=FONT_HUGE)
d2.text(((WIDTH-ws)/2, gy-80), speed_val, fill=TEXT_WHITE, font=FONT_HUGE)
d2.text(((WIDTH-100)/2, gy+80), "Mbps", fill=CYAN_BRIGHT, font=FONT_MED)

# Needle (Simple line)
needle_len = gr - 20
angle_rad = math.radians(135 + 200)
nx = gx + needle_len * math.cos(angle_rad)
ny = gy + needle_len * math.sin(angle_rad)
d2.line([gx, gy, nx, ny], fill="white", width=5)

# Status
d2.text(((WIDTH-300)/2, gy-450), "Downloading...", fill=CYAN_BRIGHT, font=FONT_MED)

img2.save("screen_2_test.png")

# ----------------- SCREEN 3: RESULT -----------------
img3 = create_canvas()
d3 = ImageDraw.Draw(img3)
draw_header(d3)

# Two main columns
draw_result_header(d3, 150, 300, "DOWNLOAD", "85.5", CYAN_BRIGHT, True)
draw_result_header(d3, 600, 300, "UPLOAD", "42.1", PURPLE_BRIGHT, False)

# Stats row
draw_stat_item(d3, 150, 700, "Ping", "12", "ms", "P", GREEN_PING)
draw_stat_item(d3, 600, 700, "Jitter", "4", "ms", "J", "orange")

# Line separator
d3.line([100, 900, WIDTH-100, 900], fill=TRACK_COLOR, width=2)

# Rating section
ry = 1000
d3.text(((WIDTH-400)/2, ry), "RATE PROVIDER", fill=TEXT_WHITE, font=FONT_MED)
d3.text(((WIDTH-300)/2, ry+60), "Moldtelecom", fill=TEXT_GREY, font=FONT_MED)

# Stars
for i in range(5):
    sx = 250 + i * 120
    # Draw star shape manually roughly
    d3.text((sx, ry+150), "★", fill=CYAN if i < 4 else TRACK_COLOR, font=ImageFont.truetype("seguiemj.ttf", 100) if "seguiemj" in str(FONT_HUGE) else FONT_HUGE)

# Restart button
by = 1500
d3.ellipse([gx-80, by-80, gx+80, by+80], outline=CYAN, width=3)
d3.text((gx-40, by-30), "GO", fill=TEXT_WHITE, font=FONT_TITLE)

img3.save("screen_3_result.png")

# ----------------- SCREEN 4: HISTORY -----------------
img4 = create_canvas()
d4 = ImageDraw.Draw(img4)
# Header back
d4.text((40, 60), "←", fill=TEXT_WHITE, font=FONT_TITLE)
d4.text((150, 60), "History", fill=TEXT_WHITE, font=FONT_TITLE)

# List items
for i in range(4):
    y = 200 + i * 320
    # Card bg
    d4.rectangle([40, y, WIDTH-40, y+280], fill=CARD_BG, outline=TRACK_COLOR, width=1)
    
    # Date
    d4.text((70, y+30), f"21.01.2026 14:{30+i}", fill=TEXT_GREY, font=FONT_SMALL)
    d4.text((WIDTH-350, y+30), "Moldtelecom", fill=TEXT_GREY, font=FONT_SMALL)
    
    # Speed row
    # Down
    d4.text((70, y+100), "↓ 85.5", fill=TEXT_WHITE, font=FONT_LARGE)
    d4.text((70, y+160), "Mbps", fill=CYAN, font=FONT_SMALL)
    
    # Up
    d4.text((400, y+100), "↑ 42.1", fill=TEXT_WHITE, font=FONT_LARGE)
    d4.text((400, y+160), "Mbps", fill=PURPLE, font=FONT_SMALL)
    
    # Ping
    d4.text((700, y+100), "⟳ 12", fill=TEXT_WHITE, font=FONT_LARGE) # ⟳ is fake ping icon
    d4.text((700, y+160), "ms", fill=GREEN_PING, font=FONT_SMALL)
    
    # Rating star mini
    if i == 0:
        d4.text((WIDTH-100, y+100), "★", fill=CYAN, font=FONT_LARGE)

img4.save("screen_4_history.png")

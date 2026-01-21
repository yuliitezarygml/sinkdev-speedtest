from PIL import Image, ImageDraw, ImageFont
import math

# Constants
WIDTH = 1080
HEIGHT = 1920
BG_COLOR = (20, 21, 38) # #141526
PRIMARY = (0, 209, 209) # #00d1d1 (Cyan)
SECONDARY = (141, 52, 230) # #8d34e6 (Purple)
TEXT_WHITE = (255, 255, 255)
TEXT_GREY = (160, 160, 160)
TRACK_COLOR = (22, 32, 50) # #162032

def create_base_image():
    return Image.new('RGB', (WIDTH, HEIGHT), BG_COLOR)

def draw_header(draw, title="SPEEDTEST"):
    # Header area
    draw.text((50, 60), "History", fill=TEXT_GREY, font=font_small)
    w = draw.textlength(title, font=font_header)
    draw.text(((WIDTH-w)/2, 60), title, fill=TEXT_WHITE, font=font_header)
    draw.text((WIDTH-120, 60), "Settings", fill=TEXT_GREY, font=font_small)

def draw_gauge(draw, value, unit="Mbps", mode="download"):
    center_x = WIDTH // 2
    center_y = HEIGHT // 2 - 100
    radius = 350
    
    # Track
    draw.arc(
        [(center_x-radius, center_y-radius), (center_x+radius, center_y+radius)],
        135, 405, fill=TRACK_COLOR, width=40
    )
    
    # Progress (approximate arc for 85.5 Mbps)
    color = PRIMARY if mode == "download" else SECONDARY
    sweep = 135 + 180 # Just an example progress
    draw.arc(
        [(center_x-radius, center_y-radius), (center_x+radius, center_y+radius)],
        135, sweep, fill=color, width=40
    )
    
    # Text
    speed_text = f"{value}"
    w_speed = draw.textlength(speed_text, font=font_huge)
    draw.text(((WIDTH-w_speed)/2, center_y + 150), speed_text, fill=TEXT_WHITE, font=font_huge)
    
    w_unit = draw.textlength(unit, font=font_medium)
    draw.text(((WIDTH-w_unit)/2, center_y + 280), unit, fill=color, font=font_medium)

def draw_stats_row(draw, y_pos, ping="12", jitter="4"):
    # Ping
    draw.text((150, y_pos), "Ping", fill=TEXT_GREY, font=font_medium)
    draw.text((250, y_pos-10), ping, fill=TEXT_WHITE, font=font_large)
    draw.text((320, y_pos+10), "ms", fill=TEXT_GREY, font=font_small)
    
    # Jitter
    draw.text((WIDTH-350, y_pos), "Jitter", fill=TEXT_GREY, font=font_medium)
    draw.text((WIDTH-230, y_pos-10), jitter, fill=TEXT_WHITE, font=font_large)
    draw.text((WIDTH-160, y_pos+10), "ms", fill=TEXT_GREY, font=font_small)

def draw_footer(draw):
    y = HEIGHT - 300
    draw.rectangle([(0, y), (WIDTH, HEIGHT)], fill=(15, 16, 30))
    
    # ISP
    draw.ellipse((50, y+50, 110, y+110), fill=TEXT_GREY)
    draw.text((140, y+50), "Moldtelecom", fill=TEXT_WHITE, font=font_large)
    draw.text((140, y+100), "192.168.1.1", fill=TEXT_GREY, font=font_small)
    
    # Server
    draw.text((140, y+170), "Orange Moldova", fill=TEXT_WHITE, font=font_large)
    draw.text((140, y+220), "Chisinau", fill=TEXT_GREY, font=font_small)

def draw_start_button(draw):
    center_x = WIDTH // 2
    center_y = HEIGHT - 500
    r = 120
    draw.ellipse((center_x-r, center_y-r, center_x+r, center_y+r), outline=PRIMARY, width=5)
    
    text = "START"
    w = draw.textlength(text, font=font_large)
    draw.text(((WIDTH-w)/2, center_y-30), text, fill=TEXT_WHITE, font=font_large)

# --- Fonts setup (using default as fallback) ---
try:
    font_huge = ImageFont.truetype("arial.ttf", 160)
    font_large = ImageFont.truetype("arial.ttf", 60)
    font_header = ImageFont.truetype("arial.ttf", 50)
    font_medium = ImageFont.truetype("arial.ttf", 40)
    font_small = ImageFont.truetype("arial.ttf", 30)
except:
    font_huge = ImageFont.load_default()
    font_large = ImageFont.load_default()
    font_header = ImageFont.load_default()
    font_medium = ImageFont.load_default()
    font_small = ImageFont.load_default()


# 1. Main Screen (Idle)
img1 = create_base_image()
d1 = ImageDraw.Draw(img1)
draw_header(d1)
draw_start_button(d1)
draw_stats_row(d1, HEIGHT//2 + 100, ping="0", jitter="0")
draw_footer(d1)
img1.save("screenshot_1_main.png")

# 2. Testing Screen (Download)
img2 = create_base_image()
d2 = ImageDraw.Draw(img2)
draw_header(d2)
d2.text((WIDTH//2 - 150, 300), "Downloading...", fill=PRIMARY, font=font_medium)
draw_gauge(d2, "85.50", "Mbps", "download")
draw_stats_row(d2, HEIGHT - 600, ping="12", jitter="4")
img2.save("screenshot_2_test.png")

# 3. Result Screen
img3 = create_base_image()
d3 = ImageDraw.Draw(img3)
d3.text((WIDTH//2 - 150, 100), "SPEEDTEST", fill=TEXT_WHITE, font=font_header)

# Big results
d3.text((150, 400), "DOWNLOAD", fill=TEXT_GREY, font=font_small)
d3.text((100, 450), "85.5", fill=TEXT_WHITE, font=font_huge)
d3.text((600, 400), "UPLOAD", fill=TEXT_GREY, font=font_small)
d3.text((550, 450), "42.1", fill=TEXT_WHITE, font=font_huge)

draw_stats_row(d3, 800, ping="12", jitter="4")

# Rating stars
star_y = 1200
for i in range(5):
    x = 300 + i * 100
    d3.text((x, star_y), "*", fill=PRIMARY, font=ImageFont.truetype("arial.ttf", 150) if "arial.ttf" in str(font_huge) else font_huge)
d3.text((320, star_y + 150), "Rate Provider", fill=TEXT_WHITE, font=font_medium)
img3.save("screenshot_3_result.png")

# 4. History Screen
img4 = create_base_image()
d4 = ImageDraw.Draw(img4)
d4.text((50, 60), "< Back", fill=TEXT_WHITE, font=font_medium)
d4.text((WIDTH//2 - 100, 60), "History", fill=TEXT_WHITE, font=font_header)

# List items
for i in range(3):
    y = 200 + i * 350
    d4.rectangle([(40, y), (WIDTH-40, y+300)], fill=(30, 31, 51), outline=(50,50,50))
    d4.text((80, y+30), f"21.01.2026 14:{30+i}", fill=TEXT_GREY, font=font_small)
    d4.text((80, y+100), "Download: 85.5", fill=PRIMARY, font=font_large)
    d4.text((80, y+180), "Upload: 42.1", fill=SECONDARY, font=font_large)
    d4.text((600, y+100), "Ping: 12ms", fill=TEXT_WHITE, font=font_medium)

img4.save("screenshot_4_history.png")

print("Screenshots generated successfully.")

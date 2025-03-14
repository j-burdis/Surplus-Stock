# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "json"
require "open-uri"

puts "Clearing existing items..."

Item.destroy_all

puts "Seeding items manually..."

chair_products = [
  {
    "name": "Modern Accent Chair",
    "category": "chair",
    "description": "Elevate your living space with this stylish mid-century modern accent chair. Featuring clean lines, comfortable cushioning, and sturdy wooden legs, it's perfect as a statement piece or additional seating in any room.",
    "price": 299.99,
    "image_path": "https://media.diy.com/is/image/KingfisherDigital/homcom-modern-armchair-accent-chair-with-rubber-wood-legs-for-bedroom-light-grey~5056725322205_01c_MP?$MOB_PREV$&$width=1200&$height=1200",
    "stock": 12,
    "discount_price": 279.99
  },
  {
    "name": "Ergonomic Office Chair",
    "category": "chair",
    "description": "Designed for comfort during long work sessions, this ergonomic office chair features adjustable height, lumbar support, and breathable mesh backing. Perfect for your home office or workspace.",
    "price": 189.99,
    "image_path": "https://www.theurbanmill.co.uk/cdn/shop/files/OC64BLifestyleImage_2.png?crop=center&height=4472&v=1731501698&width=4472",
    "stock": 25,
    "discount_price": 169.99
  },
  {
    "name": "Wooden Dining Chair",
    "category": "chair",
    "description": "Crafted from solid oak with a timeless design, these dining chairs bring elegance and comfort to any dining area. The gentle curves and sturdy construction ensure both style and durability.",
    "price": 159.99,
    "image_path": "https://idyllhome.co.uk/cdn/shop/products/KSWN06_square_0_10df7fb5-730f-4bda-98f8-dbf635639554.jpg?v=1643732220",
    "stock": 40,
    "discount_price": 139.99
  },
  {
    "name": "Velvet Accent Chair",
    "category": "chair",
    "description": "Add a touch of luxury to your living room with this plush velvet accent chair. The rich texture and deep color create a sophisticated focal point, while the comfortable seat makes it perfect for relaxing with a book or conversation.",
    "price": 249.99,
    "image_path": "https://media.4rgos.it/i/Argos/8874702_R_Z001C?w=750&h=750&qlt=70",
    "stock": 15,
    "discount_price": 219.99
  },
  {
    "name": "Modern Swivel Chair",
    "category": "chair",
    "description": "This contemporary swivel chair combines functionality with style. The 360-degree rotation allows for versatile positioning, while the sleek design fits perfectly in modern interiors. Ideal for home offices or reading nooks.",
    "price": 219.99,
    "image_path": "https://www.cultfurniture.com/images/emile-swivel-armchair-speckled-stone-sustainable-boucle-p43504-2864025_medium.jpg",
    "stock": 18,
    "discount_price": 199.99
  },
  {
    "name": "Rattan Accent Chair",
    "category": "chair",
    "description": "Bring natural texture and bohemian charm to your space with this handcrafted rattan chair. The intricate weaving pattern creates visual interest, while the sturdy frame ensures durability and comfort.",
    "price": 179.99,
    "image_path": "https://casamaria.co.uk/cdn/shop/files/Boucle_Chair_New_BG_2048x.jpg?v=1718803454",
    "stock": 22,
    "discount_price": 159.99
  },
  {
    "name": "Adirondack Outdoor Chair",
    "category": "chair",
    "description": "Perfect for patios and gardens, this classic Adirondack chair is crafted from weather-resistant wood. The iconic sloped design provides unparalleled comfort for outdoor relaxation, while the durable construction ensures years of use.",
    "price": 129.99,
    "image_path": "https://images.thdstatic.com/productImages/a947c512-bf96-4c50-a976-72a3d5f0c55e/svn/patio-festival-wood-adirondack-chairs-pf18220-64_1000.jpg",
    "stock": 30,
    "discount_price": 119.99
  },
  {
    "name": "Bentwood Dining Chair",
    "category": "chair",
    "description": "These elegant bentwood dining chairs combine classic craftsmanship with modern aesthetics. The curved backrest provides excellent support, while the sleek design complements both traditional and contemporary dining spaces.",
    "price": 149.99,
    "image_path": "https://www.daals.co.uk/cdn/shop/products/DCH-002-BLACK_main.jpg?v=1669429060",
    "stock": 24,
    "discount_price": 129.99
  }
]

table_products = [
  {
    "name": "Farmhouse Dining Table",
    "category": "table",
    "description": "This beautiful farmhouse dining table is crafted from reclaimed wood with a distressed finish. Perfect for family gatherings, it comfortably seats six and brings rustic charm to any dining space.",
    "price": 799.99,
    "image_path": "https://www.ioliving.co.uk/wp-content/uploads/2018/08/Modern-Farmhouse-1.6m-Table-With-Small-Bench-1.jpg",
    "stock": 8,
    "discount_price": 699.99
  },
  {
    "name": "Glass Coffee Table",
    "category": "table",
    "description": "A stunning centerpiece for any living room, this contemporary coffee table features a tempered glass top and minimalist metal frame. The sleek design complements modern interiors while providing functional surface space.",
    "price": 349.99,
    "image_path": "https://cdn11.bigcommerce.com/s-hw1ll9udnr/images/stencil/1280x1280/products/2373/2860/JF308-O_0002_Layer_2__35060.1636885561.jpg?c=1",
    "stock": 15,
    "discount_price": 299.99
  },
  {
    "name": "Industrial Side Table",
    "category": "table",
    "description": "Combining metal and wood elements, this industrial-style side table adds character to any room. The compact size makes it perfect as a bedside table or end table, while the lower shelf provides additional storage.",
    "price": 159.99,
    "image_path": "https://www.melodymaison.co.uk/images/P/industrial-side-table-with-magazine-rack_MM31208.jpg",
    "stock": 20,
    "discount_price": 139.99
  },
  {
    "name": "Extending Dining Table",
    "category": "table",
    "description": "This versatile dining table adapts to your needs with an expandable leaf system. Perfect for apartments or homes that occasionally need extra dining space, it transforms from an intimate four-person table to comfortably seating eight.",
    "price": 649.99,
    "image_path": "https://www.woods-furniture.co.uk/images/products/standard/7232_21878.jpg",
    "stock": 12,
    "discount_price": 599.99
  },
  {
    "name": "Marble Top Console Table",
    "category": "table",
    "description": "Elevate your entryway with this elegant console table featuring a genuine marble top. The slender profile fits perfectly in hallways or behind sofas, while the luxurious materials add a touch of sophistication to your space.",
    "price": 479.99,
    "image_path": "https://www.ellishomeinteriors.co.uk/product-images/5056693528685-Green-Marble-Effect-Console-Table-Bronze-Metal-Base.webp",
    "stock": 10,
    "discount_price": 449.99
  },
  {
    "name": "Round Dining Table",
    "category": "table",
    "description": "This classic pedestal dining table creates an inviting atmosphere for meals and gatherings. The round shape promotes conversation, while the solid wood construction ensures lasting durability and timeless appeal.",
    "price": 599.99,
    "image_path": "https://furniture123.co.uk/Images/JAR012_1_Supersize.jpg?width=900&height=900&v=26",
    "stock": 14,
    "discount_price": 549.99
  },
  {
    "name": "Nesting Coffee Tables",
    "category": "table",
    "description": "These versatile nesting tables provide flexible surface space that can be arranged according to your needs. The set of three tables can be displayed together or separated to serve different areas of your living space.",
    "price": 249.99,
    "image_path": "https://www.bentleydesigns.com/images/products/standard/3245_18229.jpg",
    "stock": 18,
    "discount_price": 229.99
  }
]

sofa_products = [
  {
    "name": "Mid-Century Modern Sofa",
    "category": "sofa",
    "description": "This stylish mid-century modern sofa features clean lines, tapered wooden legs, and comfortable cushioning. The durable upholstery and classic design make it a timeless addition to any living room.",
    "price": 899.99,
    "image_path": "https://www.juliettesinteriors.co.uk/wp-content/uploads/2021/02/large-mid-century-style-sofa-1-900x900.jpg",
    "stock": 10,
    "discount_price": 849.99
  },
  {
    "name": "Sectional Sofa with Chaise",
    "category": "sofa",
    "description": "Maximize your living room comfort with this spacious sectional sofa. The L-shaped design with chaise lounge provides ample seating for family and guests, while the plush cushions ensure relaxation.",
    "price": 1299.99,
    "image_path": "https://i.ebayimg.com/images/g/rrkAAOSw3FNj9xAa/s-l1600.webp",
    "stock": 8,
    "discount_price": 1199.99
  },
  {
    "name": "Compact Loveseat",
    "category": "sofa",
    "description": "Perfect for apartments or smaller living spaces, this compact loveseat offers comfortable seating without overwhelming the room. The elegant design and soft upholstery make it both stylish and cozy.",
    "price": 599.99,
    "image_path": "https://hips.hearstapps.com/vader-prod.s3.amazonaws.com/1675270879-traditional_sofa_love_seat-2_1.jpg?crop=1xw:1.00xh;center,top&resize=980:*",
    "stock": 15,
    "discount_price": 549.99
  },
  {
    "name": "Sleeper Sofa",
    "category": "sofa",
    "description": "This versatile sleeper sofa transforms from stylish seating to a comfortable bed for overnight guests. The easy-to-use pull-out mechanism and memory foam mattress ensure a restful night's sleep.",
    "price": 999.99,
    "image_path": "https://cottonfy.co.uk/cdn/shop/files/5_e2365c737ffd8b9a73a56caaebdd4f05.jpg?v=1712563594",
    "stock": 12,
    "discount_price": 949.99
  },
  {
    "name": "Velvet Chesterfield Sofa",
    "category": "sofa",
    "description": "Add a touch of luxury to your living room with this classic Chesterfield sofa. The tufted design, rolled arms, and plush velvet upholstery create a sophisticated focal point for any space.",
    "price": 1199.99,
    "image_path": "https://furniture123.co.uk/Images/A2PHE002_1_Supersize.jpg?v=25",
    "stock": 6,
    "discount_price": 1099.99
  },
  {
    "name": "Reclining Sofa",
    "category": "sofa",
    "description": "Experience ultimate comfort with this reclining sofa featuring adjustable positions for personalized relaxation. The power recline mechanism allows effortless adjustment, while the plush cushioning provides exceptional support.",
    "price": 1099.99,
    "image_path": "https://www.furniturechoice.co.uk/p/m/RS10001790/RS10001790.jpg",
    "stock": 9,
    "discount_price": 999.99
  },
  {
    "name": "Contemporary Modular Sofa",
    "category": "sofa",
    "description": "This innovative modular sofa allows you to customize your seating arrangement according to your space and needs. The individual pieces can be rearranged to create different configurations, making it perfect for evolving living spaces.",
    "price": 1499.99,
    "image_path": "https://www.juliettesinteriors.co.uk/wp-content/uploads/2022/06/luxurious-contemporary-modular-corner-sofa-1.jpg",
    "stock": 7,
    "discount_price": 1399.99
  },
  {
    "name": "Traditional 3-Seater Sofa",
    "category": "sofa",
    "description": "This classic three-seater sofa combines traditional design with modern comfort. The sturdy hardwood frame and high-density foam cushions ensure lasting durability, while the elegant silhouette complements both traditional and transitional interiors.",
    "price": 849.99,
    "image_path": "https://www.collingwoodstores.co.uk/wp-content/uploads/2024/10/59024.jpg",
    "stock": 14,
    "discount_price": 799.99
  }
]

bed_products = [
  {
    "name": "Queen Platform Bed",
    "category": "bed",
    "description": "This modern platform bed features a low-profile design with a sturdy wooden frame. The sleek silhouette and clean lines create a contemporary look, while the solid platform eliminates the need for a box spring.",
    "price": 599.99,
    "image_path": "https://pyxis.nymag.com/v1/imgs/066/115/65a3846967be8f98a2a8aa8471a524c9e7.jpg",
    "stock": 12,
    "discount_price": 549.99
  },
  {
    "name": "King Size Upholstered Bed",
    "category": "bed",
    "description": "Add luxury to your bedroom with this king-sized upholstered bed. The padded headboard provides comfortable back support for reading in bed, while the premium fabric upholstery creates a sophisticated focal point.",
    "price": 899.99,
    "image_path": "https://m.media-amazon.com/images/I/51JbluW44cL._AC_US1000_.jpg",
    "stock": 8,
    "discount_price": 849.99
  },
  {
    "name": "Twin Daybed with Trundle",
    "category": "bed",
    "description": "Perfect for guest rooms or children's bedrooms, this versatile daybed features a pull-out trundle to accommodate overnight guests. During the day, it functions as comfortable seating, converting to sleeping space when needed.",
    "price": 499.99,
    "image_path": "https://m.media-amazon.com/images/I/71Ok117RDIS._AC_SL1500_.jpg",
    "stock": 15,
    "discount_price": 469.99
  },
  {
    "name": "Four-Poster Canopy Bed",
    "category": "bed",
    "description": "Create a dramatic bedroom centerpiece with this elegant four-poster canopy bed. The tall posts and optional fabric draping add height and romance to your sleeping space, creating a retreat-like atmosphere.",
    "price": 1299.99,
    "image_path": "https://freerangingdesigns.com/cdn/shop/files/rustic-oak-four-poster-tree-bed.jpg?v=1732286795&width=2048",
    "stock": 6,
    "discount_price": 1199.99
  },
  {
    "name": "Storage Platform Bed",
    "category": "bed",
    "description": "Maximize your bedroom space with this practical storage bed featuring built-in drawers beneath the platform. The ample storage space is perfect for linens, clothing, or seasonal items, while the sturdy design provides excellent mattress support.",
    "price": 749.99,
    "image_path": "https://www.bedkings.co.uk/cdn/shop/files/leather-bed-gfw-end-lift-ottoman-bed-grey-leather-bed-kings-1112193973.jpg?v=1738411623&width=2560",
    "stock": 10,
    "discount_price": 699.99
  },
  {
    "name": "Mid-Century Modern Bed",
    "category": "bed",
    "description": "This mid-century inspired bed features tapered legs and a clean-lined headboard with gentle curves. The warm wood tones and minimalist design create a timeless look that pairs well with diverse bedroom decor styles.",
    "price": 849.99,
    "image_path": "https://i5.walmartimages.com/seo/DG-Casa-Soloman-Mid-Century-Modern-Upholstered-Platform-Bed-Frame-Queen-Size-Beige_83ddc4fc-6908-4d9d-8dea-c90d16d37974.4d641288bbdc630763c1098699b6314f.jpeg",
    "stock": 9,
    "discount_price": 799.99
  },
  {
    "name": "Adjustable Bed Base",
    "category": "bed",
    "description": "Experience customized comfort with this adjustable bed base that allows you to elevate your head and feet to find your perfect position. Features include wireless remote control, massage functions, and USB charging ports.",
    "price": 1199.99,
    "image_path": "https://i5.walmartimages.com/seo/Cottinch-Adjustable-Bed-Base-Frame-Twin-XL-for-Stress-Management-with-Massage-Remote-Control_4dcb466a-2c9e-44d0-8297-2b89758de499.1c930f1117f183f2b0b97ced2a29712f.jpeg",
    "stock": 7,
    "discount_price": 1099.99
  },
  {
    "name": "Rustic Wooden Bed Frame",
    "category": "bed",
    "description": "Bring natural warmth to your bedroom with this handcrafted rustic bed frame. Made from reclaimed wood, each piece features unique grain patterns and character marks that tell a story, creating a one-of-a-kind centerpiece for your bedroom.",
    "price": 699.99,
    "image_path": "https://pipedreamfurniture.co.uk/wp-content/uploads/2024/07/PDF05853.jpg",
    "stock": 11,
    "discount_price": 649.99
  }
]

all_products = chair_products + table_products + sofa_products + bed_products

# Create items in database
all_products.each do |product|
  Item.create!(
    name: product[:name],
    description: product[:description],
    price: product[:price],
    image_url: product[:image_path],
    stock: product[:stock],
    category: product[:category],
    discount_price: product[:discount_price],
    user_id: User.first&.id || 2 # Assign to the first user or a default user ID
  )
end

puts "Seeded #{Item.count} items successfully!"

# puts "Seeding items from API..."

# begin
#   api_url = "https://furniture-api.fly.dev/v1/products"
#   response = URI.open(api_url).read
#   data = JSON.parse(response)

#   products = data["data"] # Access the "data" array in the response

#   products.each do |product|
#     Item.create!(
#       name: product["name"],
#       description: product["description"],
#       price: product["price"],
#       image_url: product["image_path"],
#       stock: rand(40..50),
#       category: product["category"],
#       discount_price: product["discount_price"]&.round,
#       user_id: User.first&.id || 2 # Assign to the first user or a default user ID
#     )
#   end

#   puts "Seeding completed successfully!"
# rescue OpenURI::HTTPError => e
#   puts "HTTP Error: #{e.message}"
# rescue JSON::ParserError => e
#   puts "JSON Parsing Error: #{e.message}"
# rescue => e
#   puts "An unexpected error occurred: #{e.message}"
# end

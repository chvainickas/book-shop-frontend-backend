# Clear existing data
puts "Clearing existing data..."
Book.destroy_all
Category.destroy_all

# Create admin user
puts "Creating admin user..."
admin = User.find_or_create_by(email: 'admin@bookshop.com') do |user|
  user.password = 'admin123'
  user.password_confirmation = 'admin123'
  user.admin = true
end
Cart.create(user: admin) unless admin.cart
puts "Admin user created: #{admin.email} (password: admin123)"

# Create regular user
puts "Creating regular user..."
regular_user = User.find_or_create_by(email: 'user@bookshop.com') do |user|
  user.password = 'user123'
  user.password_confirmation = 'user123'
  user.admin = false
end
Cart.create(user: regular_user) unless regular_user.cart
puts "Regular user created: #{regular_user.email} (password: user123)"

# Create categories
puts "\nCreating categories..."
categories = {
  fiction: Category.create!(name: "Fiction"),
  fantasy: Category.create!(name: "Fantasy & Sci-Fi"),
  classic: Category.create!(name: "Classic Literature"),
  romance: Category.create!(name: "Romance"),
  dystopian: Category.create!(name: "Dystopian"),
  adventure: Category.create!(name: "Adventure"),
  philosophy: Category.create!(name: "Philosophy & Poetry"),
  horror: Category.create!(name: "Horror & Gothic")
}
puts "Created #{Category.count} categories"

# Create sample books
puts "\nCreating sample books..."

books_data = [
  {
    title: "To Kill a Mockingbird",
    author: "Harper Lee",
    price: 12.99,
    stock: 15,
    description: "A gripping, heart-wrenching, and wholly remarkable tale of coming-of-age in a South poisoned by virulent prejudice.",
    category: categories[:classic]
  },
  {
    title: "1984",
    author: "George Orwell",
    price: 14.99,
    stock: 20,
    description: "A dystopian social science fiction novel and cautionary tale about the dangers of totalitarianism.",
    category: categories[:dystopian]
  },
  {
    title: "Pride and Prejudice",
    author: "Jane Austen",
    price: 11.99,
    stock: 12,
    description: "A romantic novel of manners that follows the character development of Elizabeth Bennet.",
    category: categories[:romance]
  },
  {
    title: "The Great Gatsby",
    author: "F. Scott Fitzgerald",
    price: 13.99,
    stock: 18,
    description: "A novel set in the Jazz Age that explores themes of decadence, idealism, and social upheaval.",
    category: categories[:classic]
  },
  {
    title: "Moby-Dick",
    author: "Herman Melville",
    price: 15.99,
    stock: 10,
    description: "The narrative of Captain Ahab's obsessive quest to seek revenge on Moby Dick, the giant white whale.",
    category: categories[:adventure]
  },
  {
    title: "The Catcher in the Rye",
    author: "J.D. Salinger",
    price: 12.49,
    stock: 14,
    description: "A story about teenage rebellion and alienation narrated by Holden Caulfield.",
    category: categories[:classic]
  },
  {
    title: "Jane Eyre",
    author: "Charlotte Brontë",
    price: 13.49,
    stock: 16,
    description: "A coming-of-age story following the emotions and experiences of its eponymous heroine.",
    category: categories[:romance]
  },
  {
    title: "The Hobbit",
    author: "J.R.R. Tolkien",
    price: 16.99,
    stock: 25,
    description: "A fantasy novel about the quest of home-loving hobbit Bilbo Baggins to win a share of treasure guarded by a dragon.",
    category: categories[:fantasy]
  },
  {
    title: "Brave New World",
    author: "Aldous Huxley",
    price: 14.49,
    stock: 13,
    description: "A dystopian novel set in a futuristic World State of genetically modified citizens.",
    category: categories[:dystopian]
  },
  {
    title: "The Lord of the Rings",
    author: "J.R.R. Tolkien",
    price: 24.99,
    stock: 8,
    description: "An epic high-fantasy novel about the quest to destroy the One Ring and defeat the Dark Lord Sauron.",
    category: categories[:fantasy]
  },
  {
    title: "Harry Potter and the Sorcerer's Stone",
    author: "J.K. Rowling",
    price: 18.99,
    stock: 30,
    description: "The first novel in the Harry Potter series, following a young wizard's journey at Hogwarts School.",
    category: categories[:fantasy]
  },
  {
    title: "The Chronicles of Narnia",
    author: "C.S. Lewis",
    price: 22.99,
    stock: 11,
    description: "A series of seven fantasy novels set in the magical land of Narnia.",
    category: categories[:fantasy]
  },
  {
    title: "Animal Farm",
    author: "George Orwell",
    price: 10.99,
    stock: 22,
    description: "A satirical allegorical novella reflecting events leading up to the Russian Revolution and the Stalin era.",
    category: categories[:dystopian]
  },
  {
    title: "The Odyssey",
    author: "Homer",
    price: 14.99,
    stock: 9,
    description: "An ancient Greek epic poem attributed to Homer, recounting Odysseus's journey home after the Trojan War.",
    category: categories[:philosophy]
  },
  {
    title: "Wuthering Heights",
    author: "Emily Brontë",
    price: 12.99,
    stock: 14,
    description: "A tale of passion and revenge on the Yorkshire moors.",
    category: categories[:romance]
  },
  {
    title: "The Divine Comedy",
    author: "Dante Alighieri",
    price: 17.99,
    stock: 7,
    description: "An epic poem describing Dante's journey through Hell, Purgatory, and Paradise.",
    category: categories[:philosophy]
  },
  {
    title: "Crime and Punishment",
    author: "Fyodor Dostoevsky",
    price: 15.99,
    stock: 10,
    description: "A psychological thriller focusing on the mental anguish of Rodion Raskolnikov.",
    category: categories[:classic]
  },
  {
    title: "The Brothers Karamazov",
    author: "Fyodor Dostoevsky",
    price: 18.99,
    stock: 8,
    description: "A philosophical novel that delves into faith, doubt, and morality.",
    category: categories[:philosophy]
  },
  {
    title: "War and Peace",
    author: "Leo Tolstoy",
    price: 19.99,
    stock: 6,
    description: "An epic novel chronicling the French invasion of Russia and its impact on society.",
    category: categories[:classic]
  },
  {
    title: "Anna Karenina",
    author: "Leo Tolstoy",
    price: 16.99,
    stock: 9,
    description: "A tragic love story set in Russian high society.",
    category: categories[:romance]
  },
  {
    title: "The Picture of Dorian Gray",
    author: "Oscar Wilde",
    price: 11.99,
    stock: 15,
    description: "A philosophical novel about a man who sells his soul for eternal youth.",
    category: categories[:philosophy]
  },
  {
    title: "Frankenstein",
    author: "Mary Shelley",
    price: 10.99,
    stock: 18,
    description: "A Gothic novel about a scientist who creates a living being from dead matter.",
    category: categories[:horror]
  },
  {
    title: "Dracula",
    author: "Bram Stoker",
    price: 12.99,
    stock: 16,
    description: "The classic vampire novel that has inspired countless adaptations.",
    category: categories[:horror]
  },
  {
    title: "The Count of Monte Cristo",
    author: "Alexandre Dumas",
    price: 17.99,
    stock: 11,
    description: "An adventure novel about wrongful imprisonment, escape, and revenge.",
    category: categories[:adventure]
  },
  {
    title: "Les Misérables",
    author: "Victor Hugo",
    price: 19.99,
    stock: 7,
    description: "A French historical novel covering themes of law, justice, and redemption.",
    category: categories[:classic]
  },
  {
    title: "Don Quixote",
    author: "Miguel de Cervantes",
    price: 18.99,
    stock: 8,
    description: "The adventures of a Spanish nobleman who reads so many chivalric romances he loses his mind.",
    category: categories[:adventure]
  },
  {
    title: "One Hundred Years of Solitude",
    author: "Gabriel García Márquez",
    price: 16.99,
    stock: 12,
    description: "A landmark novel chronicling seven generations of the Buendía family.",
    category: categories[:fiction]
  },
  {
    title: "The Alchemist",
    author: "Paulo Coelho",
    price: 13.99,
    stock: 25,
    description: "A philosophical book about following one's dreams and listening to one's heart.",
    category: categories[:philosophy]
  },
  {
    title: "The Little Prince",
    author: "Antoine de Saint-Exupéry",
    price: 9.99,
    stock: 30,
    description: "A poetic tale about a young prince who visits various planets, including Earth.",
    category: categories[:philosophy]
  },
  {
    title: "Alice's Adventures in Wonderland",
    author: "Lewis Carroll",
    price: 10.99,
    stock: 20,
    description: "A whimsical tale of a girl who falls down a rabbit hole into a fantasy world.",
    category: categories[:fantasy]
  },
  {
    title: "The Adventures of Huckleberry Finn",
    author: "Mark Twain",
    price: 11.99,
    stock: 13,
    description: "A novel about a boy's journey down the Mississippi River.",
    category: categories[:adventure]
  },
  {
    title: "The Adventures of Tom Sawyer",
    author: "Mark Twain",
    price: 10.99,
    stock: 14,
    description: "The story of a mischievous boy growing up along the Mississippi River.",
    category: categories[:adventure]
  },
  {
    title: "Lord of the Flies",
    author: "William Golding",
    price: 12.99,
    stock: 17,
    description: "A novel about a group of British boys stranded on an uninhabited island.",
    category: categories[:fiction]
  },
  {
    title: "Of Mice and Men",
    author: "John Steinbeck",
    price: 11.99,
    stock: 15,
    description: "A novella about two displaced migrant workers during the Great Depression.",
    category: categories[:fiction]
  },
  {
    title: "The Grapes of Wrath",
    author: "John Steinbeck",
    price: 15.99,
    stock: 10,
    description: "A novel about a family's migration from Oklahoma to California during the Dust Bowl.",
    category: categories[:fiction]
  },
  {
    title: "Fahrenheit 451",
    author: "Ray Bradbury",
    price: 13.99,
    stock: 18,
    description: "A dystopian novel about a future American society where books are outlawed.",
    category: categories[:dystopian]
  },
  {
    title: "The Handmaid's Tale",
    author: "Margaret Atwood",
    price: 14.99,
    stock: 16,
    description: "A dystopian novel set in a totalitarian society facing environmental disasters.",
    category: categories[:dystopian]
  },
  {
    title: "The Road",
    author: "Cormac McCarthy",
    price: 13.99,
    stock: 11,
    description: "A post-apocalyptic tale of a father and son's journey through a destroyed America.",
    category: categories[:dystopian]
  },
  {
    title: "Slaughterhouse-Five",
    author: "Kurt Vonnegut",
    price: 12.99,
    stock: 14,
    description: "A satirical novel about Billy Pilgrim's experiences during World War II.",
    category: categories[:fiction]
  },
  {
    title: "Catch-22",
    author: "Joseph Heller",
    price: 14.99,
    stock: 12,
    description: "A satirical novel set during World War II about the absurdity of war.",
    category: categories[:fiction]
  },
  {
    title: "The Stranger",
    author: "Albert Camus",
    price: 11.99,
    stock: 15,
    description: "An existentialist novel about a man who commits murder and is condemned to death.",
    category: categories[:philosophy]
  },
  {
    title: "The Trial",
    author: "Franz Kafka",
    price: 12.99,
    stock: 13,
    description: "A novel about a man arrested and prosecuted by an inaccessible authority.",
    category: categories[:philosophy]
  },
  {
    title: "The Metamorphosis",
    author: "Franz Kafka",
    price: 9.99,
    stock: 19,
    description: "A novella about a man who wakes up to find himself transformed into an insect.",
    category: categories[:philosophy]
  },
  {
    title: "A Tale of Two Cities",
    author: "Charles Dickens",
    price: 14.99,
    stock: 11,
    description: "A historical novel set in London and Paris before and during the French Revolution.",
    category: categories[:classic]
  },
  {
    title: "Great Expectations",
    author: "Charles Dickens",
    price: 13.99,
    stock: 12,
    description: "A coming-of-age novel depicting the growth and personal development of Pip.",
    category: categories[:classic]
  },
  {
    title: "Oliver Twist",
    author: "Charles Dickens",
    price: 12.99,
    stock: 14,
    description: "The story of an orphan boy in Victorian London.",
    category: categories[:classic]
  },
  {
    title: "Emma",
    author: "Jane Austen",
    price: 11.99,
    stock: 13,
    description: "A comedy of manners about a young woman's misguided matchmaking attempts.",
    category: categories[:romance]
  },
  {
    title: "Sense and Sensibility",
    author: "Jane Austen",
    price: 11.99,
    stock: 12,
    description: "A novel about the Dashwood sisters as they come of age.",
    category: categories[:romance]
  },
  {
    title: "The Scarlet Letter",
    author: "Nathaniel Hawthorne",
    price: 10.99,
    stock: 15,
    description: "A novel about a woman forced to wear a scarlet A for adultery in Puritan Massachusetts.",
    category: categories[:classic]
  }
]

books_data.each do |book_data|
  book = Book.create!(book_data)
  puts "Created: #{book.title} by #{book.author}"
end

puts "\n#{Book.count} books created successfully!"
puts "All books will display the placeholder image by default."

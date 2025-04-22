-- CREATE TABLE: Customers
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20)
);

-- CREATE TABLE: Venues
CREATE TABLE venues (
    venue_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT,
    capacity INTEGER CHECK (capacity >= 0)
);

-- CREATE TABLE: Events
CREATE TABLE events (
    event_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    date DATE NOT NULL,
    venue_id INTEGER REFERENCES venues(venue_id) ON DELETE CASCADE
);

-- CREATE TABLE: Ticket Types
CREATE TABLE ticket_types (
    ticket_id SERIAL PRIMARY KEY,
    event_id INTEGER REFERENCES events(event_id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    quantity_available INTEGER NOT NULL CHECK (quantity_available >= 0)
);

-- CREATE TABLE: Orders
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id) ON DELETE SET NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount NUMERIC(10, 2) NOT NULL CHECK (total_amount >= 0)
);

--  CREATE TABLE: Order Items
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    ticket_id INTEGER REFERENCES ticket_types(ticket_id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price_per_ticket NUMERIC(10, 2) NOT NULL CHECK (price_per_ticket >= 0)
);

Show orders with customer and event info
SELECT 
    o.order_id,
    c.name AS customer,
    e.name AS event,
    t.type AS ticket_type,
    oi.quantity,
    oi.price_per_ticket,
    o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN tickets t ON oi.ticket_id = t.ticket_id
JOIN events e ON t.event_id = e.event_id;


CREATE TABLE promo_codes (
    promo_code_id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_percent NUMERIC(5,2) CHECK (discount_percent BETWEEN 0 AND 100),
    valid_from DATE,
    valid_to DATE
);

-- Track applied promos per order
ALTER TABLE orders ADD COLUMN promo_code_id INTEGER REFERENCES promo_codes(promo_code_id);


CREATE TABLE seats (
    seat_id SERIAL PRIMARY KEY,
    venue_id INTEGER REFERENCES venues(venue_id),
    section VARCHAR(50),
    row VARCHAR(10),
    seat_number VARCHAR(10),
    UNIQUE (venue_id, section, row, seat_number)
);

-- Link tickets to specific seats
ALTER TABLE tickets ADD COLUMN seat_id INTEGER REFERENCES seats(seat_id);
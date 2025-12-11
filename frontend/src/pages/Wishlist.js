// frontend/src/pages/Wishlist.js

import React, { useState, useEffect } from 'react';
import { Container, Row, Col, Card, Button, Alert, Spinner } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { wishlistAPI, cartAPI } from '../services/api';

// Helper function to safely format prices
const formatPrice = (value) => {
  const num = Number(value);
  return isNaN(num) ? '0.00' : num.toFixed(2);
};

const Wishlist = () => {
  const [wishlistItems, setWishlistItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  useEffect(() => {
    fetchWishlist();
  }, []);

  const fetchWishlist = async () => {
    try {
      setLoading(true);
      const response = await wishlistAPI.get();
      setWishlistItems(response.data.wishlist_items);
    } catch (error) {
      setError('Failed to load wishlist');
      console.error('Error fetching wishlist:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleAddToCart = async (bookId, bookTitle) => {
    try {
      await cartAPI.addItem(bookId);
      setSuccess(`${bookTitle} added to cart!`);
      setTimeout(() => setSuccess(''), 3000);
    } catch (error) {
      setError('Failed to add to cart');
      console.error('Error adding to cart:', error);
    }
  };

  const handleRemoveFromWishlist = async (itemId, bookTitle) => {
    try {
      await wishlistAPI.removeItem(itemId);
      setSuccess(`${bookTitle} removed from wishlist`);
      setTimeout(() => setSuccess(''), 3000);
      await fetchWishlist();
    } catch (error) {
      setError('Failed to remove from wishlist');
      console.error('Error removing from wishlist:', error);
    }
  };

  if (loading) {
    return (
      <Container className="text-center mt-5">
        <Spinner animation="border" role="status">
          <span className="visually-hidden">Loading...</span>
        </Spinner>
      </Container>
    );
  }

  return (
    <Container>
      <h1 className="mb-4">My Wishlist</h1>

      {error && <Alert variant="danger" onClose={() => setError('')} dismissible>{error}</Alert>}
      {success && <Alert variant="success" onClose={() => setSuccess('')} dismissible>{success}</Alert>}

      {wishlistItems.length === 0 ? (
        <Alert variant="info">
          Your wishlist is empty. <Link to="/">Browse books</Link> to add items.
        </Alert>
      ) : (
        <Row>
          {wishlistItems.map((item) => (
            <Col key={item.id} sm={6} md={4} lg={3} className="mb-4">
              <Card className="h-100">
                {item.book.image_url ? (
                  <Card.Img
                    variant="top"
                    src={item.book.image_url}
                    style={{ height: '250px', objectFit: 'cover' }}
                  />
                ) : (
                  <div
                    className="bg-secondary d-flex align-items-center justify-content-center"
                    style={{ height: '250px' }}
                  >
                    <span className="text-white">No Image</span>
                  </div>
                )}
                <Card.Body className="d-flex flex-column">
                  <Card.Title className="text-truncate" title={item.book.title}>
                    {item.book.title}
                  </Card.Title>
                  <Card.Text className="text-muted mb-1">{item.book.author}</Card.Text>
                  <Card.Text className="fw-bold mb-2">
                    €{formatPrice(item.book.price)}
                  </Card.Text>
                  <Card.Text className="small mb-3">
                    {item.book.stock > 0 ? (
                      <span className="text-success">In Stock ({item.book.stock})</span>
                    ) : (
                      <span className="text-danger">Out of Stock</span>
                    )}
                  </Card.Text>

                  <div className="mt-auto">
                    <Link
                      to={`/books/${item.book.id}`}
                      className="btn btn-primary btn-sm w-100 mb-2"
                    >
                      View Details
                    </Link>
                    {item.book.stock > 0 && (
                      <Button
                        variant="success"
                        size="sm"
                        className="w-100 mb-2"
                        onClick={() => handleAddToCart(item.book.id, item.book.title)}
                      >
                        Add to Cart
                      </Button>
                    )}
                    <Button
                      variant="outline-danger"
                      size="sm"
                      className="w-100"
                      onClick={() =>
                        handleRemoveFromWishlist(item.id, item.book.title)
                      }
                    >
                      Remove from Wishlist
                    </Button>
                  </div>
                </Card.Body>
              </Card>
            </Col>
          ))}
        </Row>
      )}
    </Container>
  );
};

export default Wishlist;

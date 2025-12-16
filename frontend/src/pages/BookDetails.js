// frontend/src/pages/BookDetails.js
// single book detail page - shows full book info with add to cart/wishlist options

import React, { useState, useEffect, useCallback } from 'react';
import { Container, Row, Col, Card, Button, Form, Alert, Spinner } from 'react-bootstrap';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { booksAPI, cartAPI, wishlistAPI } from '../services/api';
import { useAuth } from '../context/AuthContext';

// Helper function to safely format prices
const formatPrice = (value) => {
  const num = Number(value);
  return isNaN(num) ? '0.00' : num.toFixed(2);
};

const BookDetails = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { isAuthenticated, isAdmin } = useAuth();

  const [book, setBook] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [quantity, setQuantity] = useState(1);

  const fetchBook = useCallback(async () => {
    try {
      setLoading(true);
      const response = await booksAPI.getById(id);
      setBook(response.data.book);
    } catch (error) {
      setError('Failed to load book details');
      console.error('Error fetching book:', error);
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    fetchBook();
  }, [fetchBook]);

  const handleAddToCart = async () => {
    try {
      await cartAPI.addItem(book.id, quantity);
      setSuccess(`${book.title} added to cart!`);
      setTimeout(() => setSuccess(''), 3000);
    } catch (error) {
      setError('Failed to add to cart');
      console.error('Error adding to cart:', error);
    }
  };

  const handleAddToWishlist = async () => {
    try {
      await wishlistAPI.addItem(book.id);
      setSuccess(`${book.title} added to wishlist!`);
      setTimeout(() => setSuccess(''), 3000);
    } catch (error) {
      if (error.response?.data?.errors) {
        setError(error.response.data.errors.join(', '));
      } else {
        setError('Failed to add to wishlist');
      }
      console.error('Error adding to wishlist:', error);
    }
  };

  const handleDelete = async () => {
    if (!window.confirm('Are you sure you want to delete this book?')) {
      return;
    }

    try {
      await booksAPI.delete(book.id);
      navigate('/');
    } catch (error) {
      setError('Failed to delete book');
      console.error('Error deleting book:', error);
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

  if (!book) {
    return (
      <Container className="mt-5">
        <Alert variant="danger">Book not found</Alert>
        <Link to="/" className="btn btn-primary">Back to Books</Link>
      </Container>
    );
  }

  return (
    <Container>
      <Link to="/" className="btn btn-outline-primary mb-3">
        &larr; Back to Books
      </Link>

      {error && <Alert variant="danger" onClose={() => setError('')} dismissible>{error}</Alert>}
      {success && <Alert variant="success" onClose={() => setSuccess('')} dismissible>{success}</Alert>}

      <Row>
        <Col md={5}>
          {book.image_url ? (
            <Card.Img src={book.image_url} alt={book.title} className="img-fluid rounded" />
          ) : (
            <div
              className="bg-secondary d-flex align-items-center justify-content-center rounded"
              style={{ height: '400px' }}
            >
              <span className="text-white fs-4">No Image Available</span>
            </div>
          )}
        </Col>

        <Col md={7}>
          <h1>{book.title}</h1>
          <h4 className="text-muted mb-3">{book.author}</h4>

          {book.category && (
            <p className="mb-2">
              <strong>Category:</strong> {book.category.name}
            </p>
          )}

          <h3 className="text-primary mb-3">€{formatPrice(book.price)}</h3>

          <p className="mb-3">
            <strong>Stock:</strong>{' '}
            {book.stock > 0 ? (
              <span className="text-success">{book.stock} available</span>
            ) : (
              <span className="text-danger">Out of Stock</span>
            )}
          </p>

          {book.description && (
            <div className="mb-4">
              <h5>Description</h5>
              <p>{book.description}</p>
            </div>
          )}

          {isAuthenticated && book.stock > 0 && (
            <Card className="mb-3">
              <Card.Body>
                <Form.Group className="mb-3">
                  <Form.Label>Quantity</Form.Label>
                  <Form.Control
                    type="number"
                    min="1"
                    max={book.stock}
                    value={quantity}
                    onChange={(e) => setQuantity(parseInt(e.target.value) || 1)}
                    style={{ width: '100px' }}
                  />
                </Form.Group>

                <Button
                  variant="success"
                  size="lg"
                  className="w-100 mb-2"
                  onClick={handleAddToCart}
                >
                  Add to Cart
                </Button>

                <Button
                  variant="outline-secondary"
                  size="lg"
                  className="w-100"
                  onClick={handleAddToWishlist}
                >
                  Add to Wishlist
                </Button>
              </Card.Body>
            </Card>
          )}

          {!isAuthenticated && (
            <Alert variant="info">
              Please <Link to="/login">login</Link> to add items to your cart
            </Alert>
          )}

          {isAdmin && (
            <div className="mt-4">
              <h5>Admin Actions</h5>
              <Link
                to={`/admin/books/${book.id}/edit`}
                className="btn btn-warning me-2"
              >
                Edit Book
              </Link>
              <Button variant="danger" onClick={handleDelete}>
                Delete Book
              </Button>
            </div>
          )}
        </Col>
      </Row>
    </Container>
  );
};

export default BookDetails;

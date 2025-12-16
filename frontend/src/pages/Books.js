// frontend/src/pages/Books.js
// main book listing page - displays all books with filtering, search and pagination

import React, { useState, useEffect, useCallback } from 'react';
import { Container, Row, Col, Card, Button, Form, Alert, Spinner, Pagination } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { booksAPI, categoriesAPI, cartAPI, wishlistAPI } from '../services/api';
import { useAuth } from '../context/AuthContext';

// Helper function to safely format prices
const formatPrice = (value) => {
  const num = Number(value);
  return isNaN(num) ? '0.00' : num.toFixed(2);
};

const Books = () => {
  const [books, setBooks] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [pagination, setPagination] = useState({});

  // Filters
  const [categoryId, setCategoryId] = useState('');
  const [searchQuery, setSearchQuery] = useState('');
  const [sortBy, setSortBy] = useState('newest');
  const [currentPage, setCurrentPage] = useState(1);

  const { isAuthenticated } = useAuth();

  const fetchCategories = useCallback(async () => {
    try {
      const response = await categoriesAPI.getAll();
      setCategories(response.data.categories);
    } catch (error) {
      console.error('Error fetching categories:', error);
    }
  }, []);

  const fetchBooks = useCallback(async () => {
    try {
      setLoading(true);
      const params = {
        category_id: categoryId,
        query: searchQuery,
        sort: sortBy,
        page: currentPage,
      };
      const response = await booksAPI.getAll(params);
      setBooks(response.data.books);
      setPagination(response.data.pagination);
    } catch (error) {
      setError('Failed to load books');
      console.error('Error fetching books:', error);
    } finally {
      setLoading(false);
    }
  }, [categoryId, searchQuery, sortBy, currentPage]);

  useEffect(() => {
    fetchCategories();
  }, [fetchCategories]);

  useEffect(() => {
    fetchBooks();
  }, [fetchBooks]);

  const handleAddToCart = async (bookId, bookTitle) => {
    if (!isAuthenticated) {
      setError('Please login to add items to cart');
      return;
    }

    try {
      await cartAPI.addItem(bookId);
      setSuccess(`${bookTitle} added to cart!`);
      setTimeout(() => setSuccess(''), 3000);
    } catch (error) {
      setError('Failed to add to cart');
      console.error('Error adding to cart:', error);
    }
  };

  const handleAddToWishlist = async (bookId, bookTitle) => {
    if (!isAuthenticated) {
      setError('Please login to add items to wishlist');
      return;
    }

    try {
      await wishlistAPI.addItem(bookId);
      setSuccess(`${bookTitle} added to wishlist!`);
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

  const handleSearchSubmit = (e) => {
    e.preventDefault();
    setCurrentPage(1);
    fetchBooks();
  };

  const renderPagination = () => {
    if (!pagination.total_pages || pagination.total_pages <= 1) return null;

    const items = [];
    for (let number = 1; number <= pagination.total_pages; number++) {
      items.push(
        <Pagination.Item
          key={number}
          active={number === pagination.current_page}
          onClick={() => setCurrentPage(number)}
        >
          {number}
        </Pagination.Item>
      );
    }

    return (
      <Pagination className="justify-content-center mt-4">
        <Pagination.First onClick={() => setCurrentPage(1)} disabled={currentPage === 1} />
        <Pagination.Prev
          onClick={() => setCurrentPage(currentPage - 1)}
          disabled={currentPage === 1}
        />
        {items}
        <Pagination.Next
          onClick={() => setCurrentPage(currentPage + 1)}
          disabled={currentPage === pagination.total_pages}
        />
        <Pagination.Last
          onClick={() => setCurrentPage(pagination.total_pages)}
          disabled={currentPage === pagination.total_pages}
        />
      </Pagination>
    );
  };

  if (loading && books.length === 0) {
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
      <h1 className="mb-4">Browse Books</h1>

      {error && <Alert variant="danger" onClose={() => setError('')} dismissible>{error}</Alert>}
      {success && <Alert variant="success" onClose={() => setSuccess('')} dismissible>{success}</Alert>}

      {/* Filters */}
      <Row className="mb-4">
        <Col md={4}>
          <Form.Group>
            <Form.Label>Category</Form.Label>
            <Form.Select value={categoryId} onChange={(e) => { setCategoryId(e.target.value); setCurrentPage(1); }}>
              <option value="">All Categories</option>
              {categories.map((category) => (
                <option key={category.id} value={category.id}>
                  {category.name} ({category.books_count})
                </option>
              ))}
            </Form.Select>
          </Form.Group>
        </Col>

        <Col md={4}>
          <Form onSubmit={handleSearchSubmit}>
            <Form.Group>
              <Form.Label>Search</Form.Label>
              <Form.Control
                type="text"
                placeholder="Search books..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
            </Form.Group>
          </Form>
        </Col>

        <Col md={4}>
          <Form.Group>
            <Form.Label>Sort By</Form.Label>
            <Form.Select value={sortBy} onChange={(e) => { setSortBy(e.target.value); setCurrentPage(1); }}>
              <option value="newest">Newest</option>
              <option value="title">Title (A-Z)</option>
              <option value="price_low">Price (Low to High)</option>
              <option value="price_high">Price (High to Low)</option>
            </Form.Select>
          </Form.Group>
        </Col>
      </Row>

      {/* Books Grid */}
      {books.length === 0 ? (
        <Alert variant="info">No books found. Try adjusting your filters.</Alert>
      ) : (
        <>
          <Row>
            {books.map((book) => (
              <Col key={book.id} sm={6} md={4} lg={3} className="mb-4">
                <Card className="h-100">
                  {book.image_url ? (
                    <Card.Img
                      variant="top"
                      src={book.image_url}
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
                    <Card.Title className="text-truncate" title={book.title}>
                      {book.title}
                    </Card.Title>
                    <Card.Text className="text-muted mb-1">{book.author}</Card.Text>
                    <Card.Text className="fw-bold mb-2">€{formatPrice(book.price)}</Card.Text>
                    {book.category && (
                      <Card.Text className="small text-muted mb-2">
                        {book.category.name}
                      </Card.Text>
                    )}
                    <Card.Text className="small">
                      {book.stock > 0 ? (
                        <span className="text-success">In Stock ({book.stock})</span>
                      ) : (
                        <span className="text-danger">Out of Stock</span>
                      )}
                    </Card.Text>

                    <div className="mt-auto">
                      <Link to={`/books/${book.id}`} className="btn btn-primary btn-sm w-100 mb-2">
                        View Details
                      </Link>
                      {isAuthenticated && book.stock > 0 && (
                        <>
                          <Button
                            variant="success"
                            size="sm"
                            className="w-100 mb-2"
                            onClick={() => handleAddToCart(book.id, book.title)}
                          >
                            Add to Cart
                          </Button>
                          <Button
                            variant="outline-secondary"
                            size="sm"
                            className="w-100"
                            onClick={() => handleAddToWishlist(book.id, book.title)}
                          >
                            Add to Wishlist
                          </Button>
                        </>
                      )}
                    </div>
                  </Card.Body>
                </Card>
              </Col>
            ))}
          </Row>

          {renderPagination()}
        </>
      )}
    </Container>
  );
};

export default Books;

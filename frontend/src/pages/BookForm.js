// frontend/src/pages/BookForm.js
// admin book form - handles both creating new books and editing existing ones

import React, { useState, useEffect, useCallback } from 'react';
import { Container, Form, Button, Alert, Card, Spinner } from 'react-bootstrap';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { booksAPI, categoriesAPI } from '../services/api';

// form component for creating/editing books - admin only
const BookForm = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const isEditMode = !!id;

  const [formData, setFormData] = useState({
    title: '',
    author: '',
    price: '',
    stock: '',
    description: '',
    category_id: '',
  });
  const [imageFile, setImageFile] = useState(null);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(isEditMode);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [errors, setErrors] = useState([]);

  const fetchCategories = useCallback(async () => {
    try {
      const response = await categoriesAPI.getAll();
      setCategories(response.data.categories);
    } catch (error) {
      console.error('Error fetching categories:', error);
    }
  }, []);

  const fetchBook = useCallback(async () => {
    try {
      setLoading(true);
      const response = await booksAPI.getById(id);
      const book = response.data.book;
      setFormData({
        title: book.title,
        author: book.author,
        price: book.price,
        stock: book.stock,
        description: book.description || '',
        category_id: book.category?.id || '',
      });
    } catch (error) {
      setError('Failed to load book');
      console.error('Error fetching book:', error);
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    fetchCategories();
    if (isEditMode) {
      fetchBook();
    }
  }, [fetchCategories, fetchBook, isEditMode]);

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleImageChange = (e) => {
    if (e.target.files && e.target.files[0]) {
      setImageFile(e.target.files[0]);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrors([]);
    setError('');
    setSubmitting(true);

    try {
      // Prepare form data for multipart/form-data
      const submitData = new FormData();
      submitData.append('book[title]', formData.title);
      submitData.append('book[author]', formData.author);
      submitData.append('book[price]', formData.price);
      submitData.append('book[stock]', formData.stock);
      submitData.append('book[description]', formData.description);
      submitData.append('book[category_id]', formData.category_id);

      if (imageFile) {
        submitData.append('book[image]', imageFile);
      }

      let response;
      if (isEditMode) {
        // For update, we need to use the JSON approach
        const bookData = {
          title: formData.title,
          author: formData.author,
          price: parseFloat(formData.price),
          stock: parseInt(formData.stock),
          description: formData.description,
          category_id: formData.category_id ? parseInt(formData.category_id) : null,
        };
        response = await booksAPI.update(id, bookData);
        navigate(`/books/${id}`);
      } else {
        // For create, we need to use the JSON approach
        const bookData = {
          title: formData.title,
          author: formData.author,
          price: parseFloat(formData.price),
          stock: parseInt(formData.stock),
          description: formData.description,
          category_id: formData.category_id ? parseInt(formData.category_id) : null,
        };
        response = await booksAPI.create(bookData);
        navigate(`/books/${response.data.book.id}`);
      }
    } catch (error) {
      if (error.response?.data?.errors) {
        setErrors(error.response.data.errors);
      } else {
        setError(`Failed to ${isEditMode ? 'update' : 'create'} book`);
      }
      console.error('Error submitting book:', error);
      setSubmitting(false);
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
      <Link to="/" className="btn btn-outline-primary mb-3">
        &larr; Back to Books
      </Link>

      <h1 className="mb-4">{isEditMode ? 'Edit Book' : 'Add New Book'}</h1>

      {error && <Alert variant="danger">{error}</Alert>}
      {errors.length > 0 && (
        <Alert variant="danger">
          {errors.map((err, index) => (
            <div key={index}>{err}</div>
          ))}
        </Alert>
      )}

      <Card>
        <Card.Body>
          <Form onSubmit={handleSubmit}>
            <Form.Group className="mb-3" controlId="title">
              <Form.Label>Title *</Form.Label>
              <Form.Control
                type="text"
                name="title"
                value={formData.title}
                onChange={handleChange}
                required
                placeholder="Enter book title"
              />
            </Form.Group>

            <Form.Group className="mb-3" controlId="author">
              <Form.Label>Author *</Form.Label>
              <Form.Control
                type="text"
                name="author"
                value={formData.author}
                onChange={handleChange}
                required
                placeholder="Enter author name"
              />
            </Form.Group>

            <Form.Group className="mb-3" controlId="price">
              <Form.Label>Price *</Form.Label>
              <Form.Control
                type="number"
                step="0.01"
                name="price"
                value={formData.price}
                onChange={handleChange}
                required
                placeholder="0.00"
              />
            </Form.Group>

            <Form.Group className="mb-3" controlId="stock">
              <Form.Label>Stock *</Form.Label>
              <Form.Control
                type="number"
                name="stock"
                value={formData.stock}
                onChange={handleChange}
                required
                placeholder="0"
              />
            </Form.Group>

            <Form.Group className="mb-3" controlId="category_id">
              <Form.Label>Category</Form.Label>
              <Form.Select
                name="category_id"
                value={formData.category_id}
                onChange={handleChange}
              >
                <option value="">Select a category</option>
                {categories.map((category) => (
                  <option key={category.id} value={category.id}>
                    {category.name}
                  </option>
                ))}
              </Form.Select>
            </Form.Group>

            <Form.Group className="mb-3" controlId="description">
              <Form.Label>Description</Form.Label>
              <Form.Control
                as="textarea"
                rows={5}
                name="description"
                value={formData.description}
                onChange={handleChange}
                placeholder="Enter book description"
              />
            </Form.Group>

            <Form.Group className="mb-3" controlId="image">
              <Form.Label>Book Cover Image</Form.Label>
              <Form.Control
                type="file"
                accept="image/*"
                onChange={handleImageChange}
              />
              <Form.Text className="text-muted">
                {isEditMode
                  ? 'Upload a new image to replace the current one'
                  : 'Upload a book cover image'}
              </Form.Text>
            </Form.Group>

            <div className="d-flex gap-2">
              <Button
                variant="primary"
                type="submit"
                disabled={submitting}
              >
                {submitting
                  ? isEditMode
                    ? 'Updating...'
                    : 'Creating...'
                  : isEditMode
                  ? 'Update Book'
                  : 'Create Book'}
              </Button>
              <Button
                variant="outline-secondary"
                onClick={() => navigate(isEditMode ? `/books/${id}` : '/')}
              >
                Cancel
              </Button>
            </div>
          </Form>
        </Card.Body>
      </Card>
    </Container>
  );
};

export default BookForm;

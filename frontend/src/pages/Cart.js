// frontend/src/pages/Cart.js
// shopping cart page - displays cart items with quantity controls and checkout

import React, { useState, useEffect } from 'react';
import { Container, Table, Button, Alert, Spinner, Form, Card } from 'react-bootstrap';
import { Link, useNavigate } from 'react-router-dom';
import { cartAPI, ordersAPI } from '../services/api';

// Helper function to safely format prices
const formatPrice = (value) => {
  const num = Number(value);
  return isNaN(num) ? '0.00' : num.toFixed(2);
};

const Cart = () => {
  const navigate = useNavigate();
  const [cart, setCart] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [processingOrder, setProcessingOrder] = useState(false);

  useEffect(() => {
    fetchCart();
  }, []);

  const fetchCart = async () => {
    try {
      setLoading(true);
      const response = await cartAPI.get();
      setCart(response.data.cart);
    } catch (error) {
      setError('Failed to load cart');
      console.error('Error fetching cart:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleUpdateQuantity = async (itemId, newQuantity) => {
    if (newQuantity < 1) return;

    try {
      await cartAPI.updateItem(itemId, newQuantity);
      await fetchCart();
      setSuccess('Cart updated');
      setTimeout(() => setSuccess(''), 2000);
    } catch (error) {
      setError('Failed to update quantity');
      console.error('Error updating cart:', error);
    }
  };

  const handleRemoveItem = async (itemId) => {
    try {
      await cartAPI.removeItem(itemId);
      await fetchCart();
      setSuccess('Item removed from cart');
      setTimeout(() => setSuccess(''), 2000);
    } catch (error) {
      setError('Failed to remove item');
      console.error('Error removing item:', error);
    }
  };

  const handleClearCart = async () => {
    if (!window.confirm('Are you sure you want to clear your cart?')) {
      return;
    }

    try {
      await cartAPI.clear();
      await fetchCart();
      setSuccess('Cart cleared');
      setTimeout(() => setSuccess(''), 2000);
    } catch (error) {
      setError('Failed to clear cart');
      console.error('Error clearing cart:', error);
    }
  };

  const handleCheckout = async () => {
    setProcessingOrder(true);
    setError('');

    try {
      const response = await ordersAPI.create();
      setSuccess('Order placed successfully!');
      setTimeout(() => {
        navigate(`/orders/${response.data.order.id}`);
      }, 1500);
    } catch (error) {
      if (error.response?.data?.error) {
        setError(error.response.data.error);
      } else {
        setError('Failed to create order');
      }
      console.error('Error creating order:', error);
      setProcessingOrder(false);
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

  if (!cart || cart.items.length === 0) {
    return (
      <Container>
        <h1 className="mb-4">Shopping Cart</h1>
        <Alert variant="info">
          Your cart is empty. <Link to="/">Browse books</Link> to add items.
        </Alert>
      </Container>
    );
  }

  return (
    <Container>
      <h1 className="mb-4">Shopping Cart</h1>

      {error && <Alert variant="danger" onClose={() => setError('')} dismissible>{error}</Alert>}
      {success && <Alert variant="success" onClose={() => setSuccess('')} dismissible>{success}</Alert>}

      <Card className="mb-4">
        <Card.Body>
          <Table responsive hover>
            <thead>
              <tr>
                <th>Book</th>
                <th>Price</th>
                <th>Quantity</th>
                <th>Subtotal</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {cart.items.map((item) => (
                <tr key={item.id}>
                  <td>
                    <div className="d-flex align-items-center">
                      {item.book.image_url && (
                        <img
                          src={item.book.image_url}
                          alt={item.book.title}
                          style={{ width: '60px', height: '80px', objectFit: 'cover' }}
                          className="me-3"
                        />
                      )}
                      <div>
                        <Link to={`/books/${item.book.id}`} className="text-decoration-none">
                          <strong>{item.book.title}</strong>
                        </Link>
                        <br />
                        <small className="text-muted">{item.book.author}</small>
                      </div>
                    </div>
                  </td>
                  <td className="align-middle">€{formatPrice(item.book.price)}</td>
                  <td className="align-middle">
                    <div className="d-flex align-items-center" style={{ width: '120px' }}>
                      <Button
                        variant="outline-secondary"
                        size="sm"
                        onClick={() => handleUpdateQuantity(item.id, item.quantity - 1)}
                        disabled={item.quantity <= 1}
                      >
                        -
                      </Button>
                      <Form.Control
                        type="number"
                        min="1"
                        value={item.quantity}
                        onChange={(e) =>
                          handleUpdateQuantity(item.id, parseInt(e.target.value) || 1)
                        }
                        className="mx-2 text-center"
                        style={{ width: '60px' }}
                      />
                      <Button
                        variant="outline-secondary"
                        size="sm"
                        onClick={() => handleUpdateQuantity(item.id, item.quantity + 1)}
                      >
                        +
                      </Button>
                    </div>
                  </td>
                  <td className="align-middle">
                    <strong>€{formatPrice(item.subtotal)}</strong>
                  </td>
                  <td className="align-middle">
                    <Button
                      variant="danger"
                      size="sm"
                      onClick={() => handleRemoveItem(item.id)}
                    >
                      Remove
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </Table>

          <div className="d-flex justify-content-between align-items-center mt-4">
            <Button variant="outline-danger" onClick={handleClearCart}>
              Clear Cart
            </Button>
            <div>
              <h4>
                Total: <strong className="text-primary">€{formatPrice(cart.total)}</strong>
              </h4>
              <small className="text-muted">{cart.item_count} item(s)</small>
            </div>
          </div>
        </Card.Body>
      </Card>

      <div className="d-flex justify-content-between mb-5">
        <Link to="/" className="btn btn-outline-primary">
          Continue Shopping
        </Link>
        <Button
          variant="success"
          size="lg"
          onClick={handleCheckout}
          disabled={processingOrder || cart.items.length === 0}
        >
          {processingOrder ? 'Processing...' : 'Proceed to Checkout'}
        </Button>
      </div>
    </Container>
  );
};

export default Cart;

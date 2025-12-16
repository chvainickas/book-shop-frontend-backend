// frontend/src/pages/OrderDetails.js
// single order detail page - shows full order info with all items purchased

import React, { useState, useEffect, useCallback } from 'react';
import { Container, Card, Table, Badge, Alert, Spinner, Row, Col } from 'react-bootstrap';
import { useParams, Link } from 'react-router-dom';
import { ordersAPI } from '../services/api';

// Helper function to safely format prices
const formatPrice = (value) => {
  const num = Number(value);
  return isNaN(num) ? '0.00' : num.toFixed(2);
};

const OrderDetails = () => {
  const { id } = useParams();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchOrder = useCallback(async () => {
    try {
      setLoading(true);
      const response = await ordersAPI.getById(id);
      setOrder(response.data.order);
    } catch (error) {
      setError('Failed to load order details');
      console.error('Error fetching order:', error);
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    fetchOrder();
  }, [fetchOrder]);

  const getStatusBadge = (status) => {
    const variants = {
      pending: 'warning',
      completed: 'success',
      cancelled: 'danger',
    };
    return <Badge bg={variants[status] || 'secondary'}>{status}</Badge>;
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
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

  if (!order) {
    return (
      <Container className="mt-5">
        <Alert variant="danger">Order not found</Alert>
        <Link to="/orders" className="btn btn-primary">Back to Orders</Link>
      </Container>
    );
  }

  return (
    <Container>
      <Link to="/orders" className="btn btn-outline-primary mb-3">
        &larr; Back to Orders
      </Link>

      {error && <Alert variant="danger" onClose={() => setError('')} dismissible>{error}</Alert>}

      <h1 className="mb-4">Order #{order.id}</h1>

      <Row className="mb-4">
        <Col md={6}>
          <Card>
            <Card.Header>Order Information</Card.Header>
            <Card.Body>
              <p>
                <strong>Order Date:</strong> {formatDate(order.created_at)}
              </p>
              <p>
                <strong>Status:</strong> {getStatusBadge(order.status)}
              </p>
              <p>
                <strong>Total Items:</strong> {order.items.length}
              </p>
            </Card.Body>
          </Card>
        </Col>

        <Col md={6}>
          <Card>
            <Card.Header>Order Summary</Card.Header>
            <Card.Body>
              <h3 className="text-primary">
                Total: €{formatPrice(order.total)}
              </h3>
            </Card.Body>
          </Card>
        </Col>
      </Row>

      <Card>
        <Card.Header>
          <h5 className="mb-0">Order Items</h5>
        </Card.Header>
        <Card.Body>
          <Table responsive hover>
            <thead>
              <tr>
                <th>Book</th>
                <th>Price</th>
                <th>Quantity</th>
                <th>Subtotal</th>
              </tr>
            </thead>
            <tbody>
              {order.items.map((item) => (
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
                  <td className="align-middle">€{formatPrice(item.price)}</td>
                  <td className="align-middle">{item.quantity}</td>
                  <td className="align-middle">
                    <strong>€{formatPrice(item.subtotal)}</strong>
                  </td>
                </tr>
              ))}
            </tbody>
            <tfoot>
              <tr>
                <td colSpan="3" className="text-end">
                  <strong>Total:</strong>
                </td>
                <td>
                  <h5 className="text-primary mb-0">€{formatPrice(order.total)}</h5>
                </td>
              </tr>
            </tfoot>
          </Table>
        </Card.Body>
      </Card>
    </Container>
  );
};

export default OrderDetails;

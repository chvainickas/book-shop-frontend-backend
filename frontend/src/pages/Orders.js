// frontend/src/pages/Orders.js
// order history page - displays list of all user orders with status

import React, { useState, useEffect } from 'react';
import { Container, Table, Badge, Alert, Spinner, Card } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { ordersAPI } from '../services/api';

// Helper function to safely format prices
const formatPrice = (value) => {
  const num = Number(value);
  return isNaN(num) ? '0.00' : num.toFixed(2);
};

const Orders = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      setLoading(true);
      const response = await ordersAPI.getAll();
      setOrders(response.data.orders);
    } catch (error) {
      setError('Failed to load orders');
      console.error('Error fetching orders:', error);
    } finally {
      setLoading(false);
    }
  };

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

  return (
    <Container>
      <h1 className="mb-4">My Orders</h1>

      {error && <Alert variant="danger" onClose={() => setError('')} dismissible>{error}</Alert>}

      {orders.length === 0 ? (
        <Alert variant="info">
          You haven't placed any orders yet. <Link to="/">Start shopping</Link>
        </Alert>
      ) : (
        <Card>
          <Card.Body>
            <Table responsive hover>
              <thead>
                <tr>
                  <th>Order #</th>
                  <th>Date</th>
                  <th>Items</th>
                  <th>Total</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {orders.map((order) => (
                  <tr key={order.id}>
                    <td>
                      <strong>#{order.id}</strong>
                    </td>
                    <td>{formatDate(order.created_at)}</td>
                    <td>{order.items_count} item(s)</td>
                    <td>
                      <strong>€{formatPrice(order.total)}</strong>
                    </td>
                    <td>{getStatusBadge(order.status)}</td>
                    <td>
                      <Link
                        to={`/orders/${order.id}`}
                        className="btn btn-primary btn-sm"
                      >
                        View Details
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </Table>
          </Card.Body>
        </Card>
      )}
    </Container>
  );
};

export default Orders;

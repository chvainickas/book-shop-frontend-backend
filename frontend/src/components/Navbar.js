// frontend/src/components/Navbar.js

import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Navbar as BSNavbar, Nav, Container, Button } from 'react-bootstrap';
import { useAuth } from '../context/AuthContext';

const Navbar = () => {
  const { isAuthenticated, isAdmin, user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <BSNavbar bg="dark" variant="dark" expand="lg" className="mb-4">
      <Container>
        <BSNavbar.Brand as={Link} to="/">
          Book Shop
        </BSNavbar.Brand>
        <BSNavbar.Toggle aria-controls="basic-navbar-nav" />
        <BSNavbar.Collapse id="basic-navbar-nav">
          <Nav className="me-auto">
            <Nav.Link as={Link} to="/">
              Browse Books
            </Nav.Link>
            {isAdmin && (
              <Nav.Link as={Link} to="/admin/books/new">
                Add Book
              </Nav.Link>
            )}
          </Nav>
          <Nav>
            {isAuthenticated ? (
              <>
                <Nav.Link as={Link} to="/wishlist">
                  Wishlist
                </Nav.Link>
                <Nav.Link as={Link} to="/cart">
                  Cart
                </Nav.Link>
                <Nav.Link as={Link} to="/orders">
                  Orders
                </Nav.Link>
                <Nav.Item className="d-flex align-items-center text-light mx-2">
                  Hello, {user?.name}
                </Nav.Item>
                <Button variant="outline-light" onClick={handleLogout} size="sm">
                  Logout
                </Button>
              </>
            ) : (
              <>
                <Nav.Link as={Link} to="/login">
                  Login
                </Nav.Link>
                <Nav.Link as={Link} to="/signup">
                  Sign Up
                </Nav.Link>
              </>
            )}
          </Nav>
        </BSNavbar.Collapse>
      </Container>
    </BSNavbar>
  );
};

export default Navbar;

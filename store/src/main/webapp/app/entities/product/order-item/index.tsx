import React from 'react';
import { Route } from 'react-router-dom';

import ErrorBoundaryRoutes from 'app/shared/error/error-boundary-routes';

import OrderItem from './order-item';
import OrderItemDetail from './order-item-detail';
import OrderItemUpdate from './order-item-update';
import OrderItemDeleteDialog from './order-item-delete-dialog';

const OrderItemRoutes = () => (
  <ErrorBoundaryRoutes>
    <Route index element={<OrderItem />} />
    <Route path="new" element={<OrderItemUpdate />} />
    <Route path=":id">
      <Route index element={<OrderItemDetail />} />
      <Route path="edit" element={<OrderItemUpdate />} />
      <Route path="delete" element={<OrderItemDeleteDialog />} />
    </Route>
  </ErrorBoundaryRoutes>
);

export default OrderItemRoutes;

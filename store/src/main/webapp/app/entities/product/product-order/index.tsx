import React from 'react';
import { Route } from 'react-router-dom';

import ErrorBoundaryRoutes from 'app/shared/error/error-boundary-routes';

import ProductOrder from './product-order';
import ProductOrderDetail from './product-order-detail';
import ProductOrderUpdate from './product-order-update';
import ProductOrderDeleteDialog from './product-order-delete-dialog';

const ProductOrderRoutes = () => (
  <ErrorBoundaryRoutes>
    <Route index element={<ProductOrder />} />
    <Route path="new" element={<ProductOrderUpdate />} />
    <Route path=":id">
      <Route index element={<ProductOrderDetail />} />
      <Route path="edit" element={<ProductOrderUpdate />} />
      <Route path="delete" element={<ProductOrderDeleteDialog />} />
    </Route>
  </ErrorBoundaryRoutes>
);

export default ProductOrderRoutes;

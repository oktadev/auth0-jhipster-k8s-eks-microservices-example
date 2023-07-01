import React from 'react';
import { Route } from 'react-router-dom';

import ErrorBoundaryRoutes from 'app/shared/error/error-boundary-routes';

import ProductCategory from './product-category';
import ProductCategoryDetail from './product-category-detail';
import ProductCategoryUpdate from './product-category-update';
import ProductCategoryDeleteDialog from './product-category-delete-dialog';

const ProductCategoryRoutes = () => (
  <ErrorBoundaryRoutes>
    <Route index element={<ProductCategory />} />
    <Route path="new" element={<ProductCategoryUpdate />} />
    <Route path=":id">
      <Route index element={<ProductCategoryDetail />} />
      <Route path="edit" element={<ProductCategoryUpdate />} />
      <Route path="delete" element={<ProductCategoryDeleteDialog />} />
    </Route>
  </ErrorBoundaryRoutes>
);

export default ProductCategoryRoutes;

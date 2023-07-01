import React from 'react';
import { Route } from 'react-router-dom';

import ErrorBoundaryRoutes from 'app/shared/error/error-boundary-routes';

import Shipment from './shipment';
import ShipmentDetail from './shipment-detail';
import ShipmentUpdate from './shipment-update';
import ShipmentDeleteDialog from './shipment-delete-dialog';

const ShipmentRoutes = () => (
  <ErrorBoundaryRoutes>
    <Route index element={<Shipment />} />
    <Route path="new" element={<ShipmentUpdate />} />
    <Route path=":id">
      <Route index element={<ShipmentDetail />} />
      <Route path="edit" element={<ShipmentUpdate />} />
      <Route path="delete" element={<ShipmentDeleteDialog />} />
    </Route>
  </ErrorBoundaryRoutes>
);

export default ShipmentRoutes;

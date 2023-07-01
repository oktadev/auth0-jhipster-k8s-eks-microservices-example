import { IProductCategory } from 'app/shared/model/product/product-category.model';
import { Size } from 'app/shared/model/enumerations/size.model';

export interface IProduct {
  id?: number;
  name?: string;
  description?: string | null;
  price?: number;
  itemSize?: keyof typeof Size;
  imageContentType?: string | null;
  image?: string | null;
  productCategory?: IProductCategory | null;
}

export const defaultValue: Readonly<IProduct> = {};

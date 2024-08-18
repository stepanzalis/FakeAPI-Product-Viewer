import 'dart:async';

import 'package:aktin_product_viewer/feature/products/infrastructure/dto/product_dto.dart';
import 'package:aktin_product_viewer/feature/products/infrastructure/dto/product_dto_extension.dart';
import 'package:aktin_product_viewer/feature/products/infrastructure/dto/product_entry_data_extension.dart';
import 'package:aktin_product_viewer/feature/products/infrastructure/local_sources/products_dao.dart';
import 'package:aktin_product_viewer/feature/products/infrastructure/remote_sources/products_api.dart';
import 'package:aktin_product_viewer/feature/products/infrastructure/repositories/products_repository.dart';

import '../../domain/product_entity.dart';

/// Concrete implementation of [ProductsRepository]
///
/// This implementation uses [ProductsApi] to fetch products from the network and
/// [ProductsDao] to cache products locally.
final class ProductsRepositoryImpl extends ProductsRepository {
  ProductsRepositoryImpl({
    required this.productsApi,
    required this.productsDao,
  });

  /// API service for fetching products
  final ProductsApi productsApi;

  /// DAO for caching products
  final ProductsDao productsDao;

  @override
  Future<void> saveProducts() async {
    final products = await _fetchProductsFromApi();
    await _insertProductsIntoLocalCache(products);
  }

  @override
  Stream<List<ProductEntity>> watchProducts() {
    return productsDao.products().map((products) => products.map((product) => product.toEntity()).toList());
  }

  Future<List<ProductDto>> _fetchProductsFromApi() async {
    return await productsApi.fetchProducts();
  }

  Future<void> _insertProductsIntoLocalCache(List<ProductDto> products) async {
    final productsData = products.map((dto) => dto.toLocalDataSource()).toList();
    await productsDao.insertProducts(productsData);
  }
}

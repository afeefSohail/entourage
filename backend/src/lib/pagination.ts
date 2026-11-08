export const PER_PAGE = 20;

export function paginate(page: number, perPage = PER_PAGE) {
  const safePage = Math.max(1, page);
  return {
    skip: (safePage - 1) * perPage,
    take: perPage,
  };
}

export function paginationMeta(total: number, page: number, perPage = PER_PAGE) {
  return {
    current_page: page,
    total_pages: Math.ceil(total / perPage),
    per_page: perPage,
    total_count: total,
  };
}

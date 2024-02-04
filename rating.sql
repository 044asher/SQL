CREATE TEMPORARY TABLE if NOT EXISTS est_rating
SELECT establishment.name, establishment.is_chain, establishment.chain_id, COALESCE(AVG(rate.rate), 0) AS rating
FROM Establishment
         LEFT JOIN Review ON establishment.id = review.establishment_id
         LEFT JOIN Rate ON review.id = rate.review_id
GROUP BY establishment.name, establishment.is_chain, establishment.chain_id;

CREATE TEMPORARY TABLE if not EXISTS chain_rating
SELECT establishment.name, ROUND(AVG(est_rating.rating), 2) AS rating
FROM Establishment
         JOIN est_rating  ON establishment.id = est_rating.chain_id
WHERE establishment.is_chain = TRUE
GROUP BY establishment.name;


SELECT name, ROUND(rating, 2) as rating FROM chain_rating
UNION
SELECT name, ROUND(rating, 2) as rating FROM est_rating WHERE is_chain = 0 and chain_id is null
ORDER BY rating DESC;

package com.patriot.fourlipsclover.restaurant.repository;

import com.patriot.fourlipsclover.restaurant.entity.City;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CityRepository extends JpaRepository<City, Integer> {
}

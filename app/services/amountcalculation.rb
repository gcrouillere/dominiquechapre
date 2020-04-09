class Amountcalculation
  attr_accessor :order

  def initialize(order)
    @order
  end

  def calculate_amount(order, user)
    amount_ceramique = 0
    total_weight = 0
    shipping_cost = 0
    weight_partition = 0
    remaining_cost = 0

    order.basketlines.each do |basketline|
      basketline.ceramique.offer ? ceramique_discount = basketline.ceramique.offer.discount : ceramique_discount = 0
      amount_ceramique += (basketline.ceramique.price * (1 - ceramique_discount)) * basketline.quantity
      total_weight += basketline.ceramique.weight * basketline.quantity
    end

    weight_partition = { integerDivision: total_weight / 30000, remainingWeight: total_weight % 30000 }

    if user
      max_fare = ShippingCategory.where(alpha2: user.country).where("weight >= 30000", total_weight).max.price_cents.to_f / 100
      remaining_cost = ShippingCategory.where(alpha2: user.country).where("weight >= ?", weight_partition[:remainingWeight]).min.price_cents.to_f / 100
    else
      max_fare = ShippingCategory.where(alpha2: "FR").where("weight >= 30000", total_weight).max.price_cents.to_f / 100
      remaining_cost = ShippingCategory.where(alpha2: "FR").where("weight >= ?", weight_partition[:remainingWeight]).min.price_cents.to_f / 100
    end

    shipping_cost = max_fare * weight_partition[:integerDivision] + remaining_cost

    return {total: amount_ceramique, port: shipping_cost.to_money, weight: total_weight}
  end

end



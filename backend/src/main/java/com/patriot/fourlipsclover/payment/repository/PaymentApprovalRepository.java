package com.patriot.fourlipsclover.payment.repository;

import com.patriot.fourlipsclover.payment.entity.PaymentApproval;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import javax.swing.text.html.Option;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;


@Repository
public interface PaymentApprovalRepository extends JpaRepository<PaymentApproval, Long> {

	List<PaymentApproval> findByPartnerUserId(String partnerUserId);

	Optional<Object> findByPartnerOrderId(String partnerOrderId);

	List<PaymentApproval> findByApprovedAtBetweenAndPartnerUserIdLike(LocalDateTime startAt,
			LocalDateTime endAt,
			String memberId);

	Optional<PaymentApproval> findByTid(String tid);

	List<PaymentApproval> findTop3ByPartnerUserIdOrderByApprovedAtDesc(String partnerUserId);
}

